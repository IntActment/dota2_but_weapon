-- Quaternion <-> QAngle conversions: Dota Scripting API sucks.
-- To implement some all-axis rotation animations we need to use Spherical Interpolation (Slerp) and stuff.
-- But Dota API's "SplineQuaternions" function actually useless. You can ask "Why?".
-- Icefrog guys just forgot to implement Quaternion class for Lua wrapper,
-- so actually ALL API functions those return Quaternion object, throws error about "I supposed to 
-- return Quaternion object, but oops i do not know anything about Quaternion itself so fuck off, guys" <facepalm.jpg>
-- At least, Icefrog guys implemented QAngle class (without any methods on it), and you can create it with:
--      local ang = QAngle()
-- and you can get read/write access to it values by indexing:
--      local pitch = ang[1]	-- Clockwise rotation around the Y axis
--      local yaw   = ang[2]	-- Counterclockwise rotation around the Z axis.
--      local roll  = ang[3]	-- Counterclockwise rotation around the X axis.
-- Angles are right-handed Euler angles in degrees.
--
-- I used conversion functions from here:
--    https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/mathlib/mathlib_base.cpp
--
-- Author: IntActment, 2019


local Geom = {}

Geom.PI = 3.14159265358979323846264338327950288
Geom.Deg2Rad = 0.01745329251994329576923690768489
Geom.Rad2Deg = 57.295779513082320876798154814105
Geom.Epsilon = 1.192092896e-07

-- My custom partial implementation of Quaternion
Geom.Quat = class({x = 0, y = 0, z = 0, w = 0})


-- Raw values -> Quaternion (Constructor)
function Geom.Quat:FromValues(x, y, z, w)
	local res = {}
	
	res.w = w
	res.x = x
	res.y = y
	res.z = z

	setmetatable(res, self)
	self.__index = self
	self.__type = "Quat"
	
	return res
end

function Geom.Quat:SlerpNoAlign( q, t )

	local omega = 0
	local sinom = 0
	local sclp = 0
	local sclq = 0

	-- 0.0 returns self, 1.0 return q.

	local cosom = self.x * q.x + self.y * q.y + self.z * q.z + self.w * q.w

	if ( 1.0 + cosom ) > 0.000001 then
		if ( 1.0 - cosom ) > 0.000001 then
			omega = math.acos( cosom )
			sinom = math.sin( omega )
			sclp = math.sin( ( 1.0 - t ) * omega ) / sinom
			sclq = math.sin( t * omega ) / sinom
		else
			-- TODO: add short circuit for cosom == 1.0f?
			sclp = 1.0 - t
			sclq = t
		end
		
		return Geom.Quat:FromValues( 
			sclp * self.x + sclq * q.x,
			sclp * self.y + sclq * q.y,
			sclp * self.z + sclq * q.z,
			sclp * self.w + sclq * q.w
			)
	else
		local qt = Geom.Quat:FromValues( -q.y, q.x, -q.w, q.z )
		
		sclp = math.sin( ( 1.0 - t ) * ( 0.5 * Geom.PI ) )
		sclq = math.sin( t * ( 0.5 * Geom.PI ) )
		
		qt.x = sclp * self.x + sclq * qt.x
		qt.y = sclp * self.y + sclq * qt.y
		qt.z = sclp * self.z + sclq * qt.z
		qt.w = sclp * self.w + sclq * qt.w
		
		return qt
	end
end


-- Quaternion -> 3x4 matrix conversion
function Geom.Quat:QuaternionMatrix()

	local matrix = {}
	matrix[1] = {}
	matrix[2] = {}
	matrix[3] = {}
	
	local q = self
	
-- Original code
-- This should produce the same code as below with optimization, but looking at the assmebly,
-- it doesn't.  There are 7 extra multiplies in the release build of this, go figure.

	matrix[1][1] = 1.0 - 2.0 * q.y * q.y - 2.0 * q.z * q.z
	matrix[2][1] = 2.0 * q.x * q.y + 2.0 * q.w * q.z
	matrix[3][1] = 2.0 * q.x * q.z - 2.0 * q.w * q.y

	matrix[1][2] = 2.0 * q.x * q.y - 2.0 * q.w * q.z
	matrix[2][2] = 1.0 - 2.0 * q.x * q.x - 2.0 * q.z * q.z
	matrix[3][2] = 2.0 * q.y * q.z + 2.0 * q.w * q.x

	matrix[1][3] = 2.0 * q.x * q.z + 2.0 * q.w * q.y
	matrix[2][3] = 2.0 * q.y * q.z - 2.0 * q.w * q.x
	matrix[3][3] = 1.0 - 2.0 * q.x * q.x - 2.0 * q.y * q.y

	matrix[1][4] = 0.0
	matrix[2][4] = 0.0
	matrix[3][4] = 0.0

	return matrix
end

-- 3x4 matrix -> QAngles conversion
Geom.MatrixAngles = function( matrix )

	local angles = QAngle()
	local forward = {}
	local left = {}
	local up = {}

	--
	-- Extract the basis vectors from the matrix. Since we only need the Z
	-- component of the up vector, we don't get X and Y.
	--
	forward[1] = matrix[1][1]
	forward[2] = matrix[2][1]
	forward[3] = matrix[3][1]
	left[1]    = matrix[1][2]
	left[2]    = matrix[2][2]
	left[3]    = matrix[3][2]
	up[3]      = matrix[3][3]

	local xyDist = math.sqrt( forward[1] * forward[1] + forward[2] * forward[2] )
	
	-- enough here to get angles?
	if  xyDist > 0.001 then
		-- (yaw)	y = ATAN( forward.y, forward.x );		-- in our space, forward is the X axis
		angles[2] = Geom.Rad2Deg * math.atan2( forward[2], forward[1] )

		-- (pitch)	x = ATAN( -forward.z, sqrt(forward.x*forward.x+forward.y*forward.y) );
		angles[1] = Geom.Rad2Deg * math.atan2( -forward[3], xyDist )

		-- (roll)	z = ATAN( left.z, up.z );
		angles[3] = Geom.Rad2Deg * math.atan2( left[3], up[3] )
	else	-- forward is mostly Z, gimbal lock-
		-- (yaw)	y = ATAN( -left.x, left.y );			-- forward is mostly z, so use right for yaw
		angles[2] = Geom.Rad2Deg * math.atan2( -left[1], left[2] )

		-- (pitch)	x = ATAN( -forward.z, sqrt(forward.x*forward.x+forward.y*forward.y) );
		angles[1] = Geom.Rad2Deg * math.atan2( -forward[3], xyDist )

		-- Assume no roll in this case as one degree of freedom has been lost (i.e. yaw == roll)
		angles[3] = 0
	end
	
	return angles
end

-- Quaternion -> QAngles conversion
function Geom.Quat:ToAngles()

	local angles = QAngle()
	
	-- FIXME: doing it this way calculates too much data, needs to do an optimized version...
	local matrix = self:QuaternionMatrix()
	angles = Geom.MatrixAngles( matrix )

	return angles
end

-- QAngles -> Quaternion conversion (Constructor)
function Geom.Quat:FromAngles( Angles )

	local outQuat = {}

	local a = {
		pitch = Geom.PI * Angles[1] / 360.0,
		yaw   = Geom.PI * Angles[2] / 360.0,
		roll  = Geom.PI * Angles[3] / 360.0,
	}
	
	local sy = math.sin( a.yaw )
	local sp = math.sin( a.pitch )
	local sr = math.sin( a.roll )
	
	local cy = math.cos( a.yaw )
	local cp = math.cos( a.pitch )
	local cr = math.cos( a.roll )

	-- NJS: for some reason VC6 wasn't recognizing the common subexpressions:
	local srXcp = sr * cp
	local crXsp = cr * sp
	
	outQuat.x = srXcp * cy - crXsp * sy -- X
	outQuat.y = crXsp * cy + srXcp * sy -- Y

	local crXcp = cr * cp
	local srXsp = sr * sp
	
	outQuat.z = crXcp * sy - srXsp * cy -- Z
	outQuat.w = crXcp * cy + srXsp * sy -- W (real component)
	
	setmetatable(outQuat, self)
	self.__index = self
	self.__type = "Quat"
	
	return outQuat
end

function Geom.Quat:Dot( quat )
	return self.x * quat.x + self.y * quat.y + self.z * quat.z + self.w * quat.w
end

function Geom.Quat.__mul( scale, quat )
	return Geom.Quat:FromValues( quat.x * scale, quat.y * scale, quat.z * scale, quat.w * scale )
end

function Geom.Quat.__div( quat, scale )
	return Geom.Quat:FromValues( quat.x / scale, quat.y / scale, quat.z / scale, quat.w / scale )
end

function Geom.Quat.__add( quat1, quat2 )
	return Geom.Quat:FromValues( quat1.x + quat2.x, quat1.y + quat2.y, quat1.z + quat2.z, quat1.w + quat2.w )
end

function Geom.Quat:Align( q )
	-- decide if one of the quaternions is backwards
	local a = ( self.x - q.x ) * ( self.x - q.x ) + ( self.y - q.y ) * ( self.y - q.y ) + ( self.z - q.z ) * ( self.z - q.z ) + ( self.w - q.w ) * ( self.w - q.w )
	local b = ( self.x + q.x ) * ( self.x + q.x ) + ( self.y + q.y ) * ( self.y + q.y ) + ( self.z + q.z ) * ( self.z + q.z ) + ( self.w + q.w ) * ( self.w + q.w )

	if a > b then
		return Geom.Quat:FromValues( -q.x, -q.y, -q.z, -q.w )
	else
		return Geom.Quat:FromValues( q.x, q.y, q.z, q.w )
	end
end

function Geom.Quat:Add( q )

	local p = self
	local q2 = p:Align( q )

	return Geom.Quat:FromValues( p.x + q2.x, p.y + q2.y, p.z + q2.z, p.w + q2.w )
end

-- Spherical interpolation between Quaternions
function Geom.Quat:Slerp( to, value )

	local q2 = self:Align( to )
	return self:SlerpNoAlign( q2, value )
end

function Geom.Quat:__tostring()
	return "Quat [x:".. self.x ..", y:".. self.y ..", z:".. self.z ..", w:".. self.w .."]"
end

-- Linear interpolation between numbers
Geom.Lerp = function(val1, val2, pos)
	return val1 + pos * (val2 - val1)
end

-- Yes, guys, some Dota API functions returns angles as Vector, not 
--  as QAngle. So we need conversion for this shit.
Geom.pyrVectorToQAngles = function(pyrVector)

	local target_qangles = QAngle()
	target_qangles[1] = pyrVector[1]
	target_qangles[2] = pyrVector[2]
	target_qangles[3] = pyrVector[3]
	
	return target_qangles
end

-- Spherical interpolation between QAngles
Geom.SplineAngles = function(Angles_1, Angles_2, value)

	local q1 = Geom.Quat:FromAngles(Angles_1)
	local q2 = Geom.Quat:FromAngles(Angles_2)
	
	return q1:Slerp(q2, value):ToAngles()
end

return Geom