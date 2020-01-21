
travelmodifier = class({})

function travelmodifier:RemoveOnDeath() return true end
function travelmodifier:IsPurgable() return false end
function travelmodifier:IsPurgeException() return false end
function travelmodifier:IsHidden() return false end

function travelmodifier:GetTexture() return "custom_teleport" end

function travelmodifier:GetAttributes()
	return self.BaseClass.GetAttributes( self )
		+ MODIFIER_ATTRIBUTE_PERMANENT
		+ MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE -- Allows modifier to be assigned to invulnerable entities. 
end

function travelmodifier:OnCreated( kv )
	if IsClient() then return end
	
	self.range = kv.range
	
	self.startPos = self:GetParent():GetAbsOrigin()
	self.startAngles = self:GetParent():GetAngles()
	
	self:SetStackCount( self.range )
	self.state = 0 -- idle

	self:StartIntervalThink( 5 )
end

function travelmodifier:OnDestroy()
	self:StartIntervalThink( -1 )
end

function travelmodifier:OnIntervalThink()
	if IsClient() then return end
	
	local parent = self:GetParent()
	
	if self.state == 0 then
		if ( self.startPos - parent:GetAbsOrigin() ):Length2D() > self.range and not parent:HasModifier( "parentedmodifier" ) then
			self.state = 1
			print( "unit " .. parent:GetName() .. " was moved too far, started TP" )

			self.tpHereFX = ParticleManager:CreateParticle( "particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
			ParticleManager:SetParticleControlEnt( self.tpHereFX, 0, parent, PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetOrigin(), false )
			
			self.tpThereFX = ParticleManager:CreateParticle( "particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ring.vpcf", PATTACH_WORLDORIGIN, parent )
			ParticleManager:SetParticleControl( self.tpThereFX, 0, self.startPos )
			
			self:StartIntervalThink( 3 )
		end
		
	elseif self.state == 1 then
		self.state = 0 -- idle
		
		if parent:HasModifier( "parentedmodifier" ) then
			ParticleManager:DestroyParticle( self.tpHereFX, false )
			ParticleManager:DestroyParticle( self.tpThereFX, false )
			print( "unit " .. parent:GetName() .. " TP was interrupted" )
		else
		
			ParticleManager:DestroyParticle( self.tpHereFX, false )
			ParticleManager:DestroyParticle( self.tpThereFX, false )
			
			parent:EmitSound("outpost_capture_notify")
			
			parent:SetAbsOrigin( self.startPos )
			parent:SetAngles( self.startAngles.x, self.startAngles.y, self.startAngles.z )
			print( "unit " .. parent:GetName() .. " TP has ended" )
		end
		
		self:StartIntervalThink( 5 )
	end
end