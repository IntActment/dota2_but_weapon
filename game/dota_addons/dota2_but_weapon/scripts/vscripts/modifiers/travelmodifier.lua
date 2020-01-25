BUTTINGS = BUTTINGS or {}

local butts = BUTTINGS

travelmodifier = class({})

function travelmodifier:RemoveOnDeath() return true end
function travelmodifier:IsPurgable() return false end
function travelmodifier:IsPurgeException() return false end


function travelmodifier:IsHidden()
	if IsClient() then return false end
	
	if butts.GNT_BEHAVIOR == 1 then
		return false
	elseif butts.GNT_BEHAVIOR == 2 then
		return true
	end
	
	print( "GNT_BEHAVIOR not set!!!" )
	
	return false
end

function travelmodifier:GetTexture() return "custom_teleport" end

function travelmodifier:GetAttributes()
	return self.BaseClass.GetAttributes( self )
		+ MODIFIER_ATTRIBUTE_PERMANENT
		+ MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE -- Allows modifier to be assigned to invulnerable entities. 
end

function travelmodifier:GetComparePos()
	if butts.GNT_BEHAVIOR == 1 then
		return self.startPos
		
	elseif butts.GNT_BEHAVIOR == 2 then
		if self.hFountain and self.hFountain:IsAlive() and not self.hFountain.HasDied then
			return self.hFountain:GetAbsOrigin()
		else
			return nil
		end
	end
end

function travelmodifier:OnCreated( kv )
	if IsClient() then return end
	
	local parent = self:GetParent()
	self.isCircleShown = false
	
	self.range = kv.range
	
	self.startPos = parent:GetAbsOrigin()
	self.startAngles = parent:GetAngles()
	
	if butts.GNT_BEHAVIOR == 2 then
		self.hFountain = nil
		local nTeam = parent:GetTeamNumber()
		
		if nTeam == DOTA_TEAM_GOODGUYS then
			self.hFountain = Entities:FindByName( nil, "ent_dota_fountain_good" )
			
		elseif nTeam == DOTA_TEAM_BADGUYS then
			self.hFountain = Entities:FindByName( nil, "ent_dota_fountain_bad" )
			
		end
		
		self.range = 1500
	end
	
	self:SetStackCount( self.range )
	self.state = 0 -- idle
	
	self.circle_part = "particles/custom/area_" .. tostring(math.floor(self.range)) .. ".vpcf"
	
	--print( "range: " .. tostring(self.range) .. ", particle: " .. self.circle_part )
	
	--DebugDrawCircle( self.startPos, Vector( RandomInt(0, 255), RandomInt(0, 255), RandomInt(0, 255) ), 16, self.range, true, 200 )

	self:StartIntervalThink( 0.3 )
end

function travelmodifier:OnDestroy()
	if IsClient() then return end
	
	self:HideCircle()
	self:StartIntervalThink( -1 )
end

function travelmodifier:OnIntervalThink()
	if IsClient() then return end
	
	local checkPos = self:GetComparePos()
	
	if checkPos == nil then		
		self:Destroy()
		return
	end
	
	local parent = self:GetParent()
	self.hParentModifier = parent:FindModifierByName( "parentedmodifier" )
	
	if self.state == 0 then
		local needToTpBack = ( checkPos - parent:GetAbsOrigin() ):Length2D() > self.range
		
		if butts.GNT_BEHAVIOR == 2 then
			needToTpBack = not needToTpBack
		end
		
		if needToTpBack then
			self.state = 1
			print( "unit " .. parent:GetName() .. " was moved too far, started TP" )
			
			self:HideCircle()
			self:DrawCircle( false )	-- draw red circle
			
			self.tpHereFX = ParticleManager:CreateParticle( "particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ring.vpcf", PATTACH_ABSORIGIN_FOLLOW, parent )
			ParticleManager:SetParticleControlEnt( self.tpHereFX, 0, parent, PATTACH_ABSORIGIN_FOLLOW, nil, parent:GetAbsOrigin(), false )
			
			self.tpThereFX = ParticleManager:CreateParticle( "particles/econ/items/tinker/boots_of_travel/teleport_start_bots_ring.vpcf", PATTACH_WORLDORIGIN, parent )
			ParticleManager:SetParticleControl( self.tpThereFX, 0, self.startPos )
			
			self:StartIntervalThink( 3 )
			
		elseif self.hParentModifier then
			self:DrawCircle( true )		-- draw green circle
		else
			self:HideCircle()			-- hide circle
		end
		
	elseif self.state == 1 then
		self.state = 0 -- idle
		
		if self.hParentModifier then
			local gm = self.hParentModifier:GetCaster():FindModifierByName( "grabmodifier" )
			if gm then
				gm:Destroy()
			end
		end
		
		ParticleManager:DestroyParticle( self.tpHereFX, false )
		ParticleManager:DestroyParticle( self.tpThereFX, false )
		
		self:HideCircle()
		
		--parent:EmitSound("outpost_capture_notify")
		
		parent:SetAbsOrigin( self.startPos )
		parent:SetAngles( self.startAngles.x, self.startAngles.y, self.startAngles.z )
		--print( "unit " .. parent:GetName() .. " TP has ended" )
		
		self:StartIntervalThink( 0.3 )
	end
end

function travelmodifier:DrawCircle( inRange )
	if IsClient() then return end
	
	local player = nil
	local checkPos = self:GetComparePos()
	
	if checkPos == nil then return end
	
	if self.hParentModifier then	
		player = PlayerResource:GetPlayer( self.hParentModifier:GetCaster():GetPlayerID() )
	end
	
	if not self.isCircleShown and player then
		self.isCircleShown = true

		local parent = self:GetParent()

		self.circleFX = ParticleManager:CreateParticleForPlayer( self.circle_part, PATTACH_CUSTOMORIGIN, parent, player )

		ParticleManager:SetParticleControl( self.circleFX, 0, checkPos )
		
		if inRange then
			ParticleManager:SetParticleControl( self.circleFX, 1, Vector( 0, 128, 255 ) )	-- green circle
		else
			ParticleManager:SetParticleControl( self.circleFX, 1, Vector( 255, 128, 0 ) )	-- red circle
		end
		
		ParticleManager:SetParticleControl( self.circleFX, 2, Vector( 1, 1, 0 ) )
	end
end

function travelmodifier:HideCircle()
	if IsClient() then return end
	
	if self.isCircleShown and self.circleFX then
		ParticleManager:DestroyParticle( self.circleFX, true )
		self.circleFX = nil
		self.isCircleShown = false
	end
end