
local Geom = require( "internal/utils/Geom" )

beingtossedmodifier = beingtossedmodifier or class({})

function beingtossedmodifier:GetTexture() return "custom_beingtossedmodifier" end

function beingtossedmodifier:RemoveOnDeath() return true end
function beingtossedmodifier:IsHidden() return false end 	-- we can hide the modifier
function beingtossedmodifier:IsDebuff() return true end 	-- make it red or green
function beingtossedmodifier:DestroyOnExpire() return true end
function beingtossedmodifier:IsStunDebuff() return true end
function beingtossedmodifier:IsPurgable() return false end

function beingtossedmodifier:GetAttributes()
	return self.BaseClass.GetAttributes( self )
		+ MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE -- Allows modifier to be assigned to invulnerable entities. 
end

function beingtossedmodifier:OnCreated( kv )
	if IsClient() then return end
	
	self.pm = self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "parentedmodifier", {} )
	
	self.tossPoint = Vector( kv.tossPointX, kv.tossPointY, kv.tossPointZ )
	self.tossStart = Vector( kv.tossFromX, kv.tossFromY, kv.tossFromZ )
	self.duration = kv.duration
	self.damage = kv.damage
	self.range = kv.range

	self.tossPoint = self.tossStart + ( self.tossPoint - self.tossStart ):Normalized() * self.range
	
	self.time_last = Time()
	self.time_start = self.time_last
	self.progress = 0.0
	
	self:StartIntervalThink( 0.01 )
end

function beingtossedmodifier:OnDestroy()
	if IsClient() then return end
	
	if self:GetRemainingTime() <= 0 then
		self:OnExpire()
	end
end

function beingtossedmodifier:OnExpire()
	
	self:GetParent():RemoveModifierByName( "parentedmodifier" )
	self.pm = nil
end

function beingtossedmodifier:OnIntervalThink()
	if IsClient() then return end
	
	local grab_target = self:GetParent()
	
	local time_now = Time()
	local time_delta = self.time_last - time_now
	
	self.progress = ( time_now - self.time_start ) / self.duration
	
	local delta = 1 - ( ( self.progress - 1 ) * ( self.progress - 1 ) * ( self.progress - 1 ) * ( self.progress - 1 ) )
	local hyp = 1 - ( ( delta - 0.5 ) * ( delta - 0.5 ) ) * 4
	
	local origin = SplineVectors( self.tossStart, self.tossPoint, delta )
		
	local grOrigin = GetGroundPosition( origin, null )
	origin.z = grOrigin.z + hyp * 180.0 + 1

	if not GridNav:IsBlocked( grOrigin ) and GridNav:IsTraversable( grOrigin ) then
		grab_target:SetAbsOrigin( origin )
	end
	
	local velocity = grab_target:GetAngles()
	velocity.z = velocity.z - 59.0 * time_delta
	velocity.y = velocity.y - 53.0 * time_delta
	velocity.x = velocity.x - 190.0 * time_delta
	grab_target:SetAngles( velocity.x, velocity.y, velocity.z )
		
	self.time_last = time_now
	
	GridNav:DestroyTreesAroundPoint( grab_target:GetAbsOrigin(), grab_target:GetHullRadius() / 2, true )
	
	local units = FindUnitsInRadius( 
		self:GetCaster():GetTeamNumber(), 
		grab_target:GetOrigin(),
		grab_target,
		grab_target:GetHullRadius() + 50,
		DOTA_UNIT_TARGET_TEAM_BOTH,
		DOTA_UNIT_TARGET_ALL + DOTA_UNIT_TARGET_CUSTOM,
		DOTA_UNIT_TARGET_FLAG_NONE,
		FIND_ANY_ORDER, 
		false )
		
	for u,unit in pairs(units) do
		if ( self:GetCaster() ~= unit ) and ( not unit:HasModifier( "getsmackedmodifier" ) ) and ( not unit:HasModifier( "parentedmodifier") ) then
			
			unit:Interrupt()
			
			local damage = {
				victim = unit,
				attacker = self:GetCaster(),
				damage = self.damage,
				damage_type = DAMAGE_TYPE_PHYSICAL,		
				ability = self:GetAbility()
			}

			ApplyDamage( damage )
			
			damage.victim = grab_target
			damage.damage = damage.damage / 2
			damage.attacker = unit
			
			ApplyDamage( damage )
			
			unit:EmitSound("smash_1")
			
			unit:AddNewModifier( self:GetCaster(), self:GetAbility(), "getsmackedmodifier", {} )
		end
	end
	
end

function beingtossedmodifier:DeclareFunctions()
	if IsClient() then return {} end
	
	return {
		--MODIFIER_EVENT_ON_ATTACK_LANDED, -- OnAttackLanded (check the link below)
		-- MODIFIER_EVENT_ON_TELEPORTED, -- OnTeleported 
		-- MODIFIER_PROPERTY_MANA_BONUS, -- GetModifierManaBonus 


		-- can contain everything from the API
		-- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API

	}
end

