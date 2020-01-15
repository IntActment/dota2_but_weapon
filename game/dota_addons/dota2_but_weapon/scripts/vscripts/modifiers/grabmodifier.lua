local function ResetBeingGrabbed(grabbingmodifier_source)
	if grabbingmodifier_source.grab_target~=nil and grabbingmodifier_source.grab_target:IsAlive() then
		grabbingmodifier_source.grab_target:RemoveModifierByName("beinggrabbedmodifier")
	end
end

local Geom = require("internal/utils/Geom")

-------------------------------------------------------------------------------------------------------------------------------

grabmodifier = class({})

function grabmodifier:GetTexture() return "custom_grabmodifier" end

function grabmodifier:OnCreated( kv )
	if IsClient() then return end
	
	local caster = self:GetCaster()
	
	self.grab_time = Time()
		
	self.tossAbility = caster:FindAbilityByName( "tossnpcability" )
	if self.tossAbility ~= nil then
		self.tossAbility:SetLevel( self:GetAbility():GetLevel() )
		self.tossAbility:SetHidden( false )
		caster:SwapAbilities( "grabnpcability", "tossnpcability", false, true )
	end
	
	self.grab_target = EntIndexToHScript(kv.targetID)
	self.move_slow_rate = kv.move_slow_rate
	self.turn_rate = kv.turn_rate
	self.duration = kv.duration
	self.cleave_rad = kv.cl_rad
	self.cleave_percentage = kv.cl_percentage
	self.stack_limit = kv.st_limit
	self.damage_increase = kv.dam_increase
	
	if not self:GetCaster():HasScepter() then
		self:SetStackCount( self.stack_limit )
	end
	
	-- remove old grabber state
	
	self.grab_target:RemoveModifierByName("beingtossedmodifier")
	
	-- now we add a modifier to grabbed unit, that makes him being grabbed
	self.grab_target:AddNewModifier(
						self:GetCaster(),
						self:GetAbility(),
						"beinggrabbedmodifier",
						{
							duration = kv.duration,
							ally = (self:GetCaster():GetTeamNumber() == self.grab_target:GetTeamNumber())
						}
	)
	
	self.weapon = caster:ScriptLookupAttachment( "attach_attack1" )		
	

	caster:EmitSound( "swing_2" )

	self.rate = 0.95
	
	self.animation = ACT_DOTA_OVERRIDE_ABILITY_4
	caster:StartGestureWithPlaybackRate( self.animation, 1 )
	
	self:StartIntervalThink( 0.01 )	
	
	--if self:GetCaster() and self:GetCaster():IsHero() then
	--	local hWeapon = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON  )
	--	if hWeapon ~= nil then
	--		hWeapon:AddEffects( EF_NODRAW )
	--	end
	--end
end

function grabmodifier:OnDestroy()
	if IsClient() then return end
	
	self:GetCaster():RemoveGesture( self.animation )

	--if self:GetRemainingTime() <= 0 then
		self:OnExpire()
	--end
	
	ResetBeingGrabbed( self )
	
	if self.tossAbility ~= nil then
		self:GetCaster():SwapAbilities("tossnpcability", "grabnpcability", false, true)
	end
	
	--if self:GetCaster() and self:GetCaster():IsHero() then
	--	local hWeapon = self:GetCaster():GetTogglableWearable( DOTA_LOADOUT_TYPE_WEAPON )
	--	if hWeapon ~= nil then
	--		print ("remove")
	--		hWeapon:RemoveEffects( EF_NODRAW )
	--	end
	--end
end

function grabmodifier:RemoveOnDeath() return true end
function grabmodifier:IsHidden() return false end 	-- we can hide the modifier
function grabmodifier:IsDebuff() return false end 	-- make it red or green
function grabmodifier:DestroyOnExpire() return true end

function grabmodifier:OnExpire()
	
	self.grab_target:RemoveModifierByName("parentedmodifier")
	
end

function grabmodifier:OnIntervalThink()
	if IsClient() then return end
	
	local caster = self:GetCaster()
	
	if self:GetCaster():HasScepter() then
		self:SetStackCount( 0 )
	end
	
	self.rate = Geom.Lerp(self.rate, 0.05, 0.05)	

	local target_qangles = caster:GetAngles()
	target_qangles[3] = -76.0
	
	local weaponAngles = caster:GetAttachmentAngles( self.weapon )
	target_qangles[1] = weaponAngles[1] - 90
	target_qangles[2] = weaponAngles[2] - 90
	target_qangles[3] = weaponAngles[3]
	
	local newOrigin = SplineVectors( caster:GetAttachmentOrigin( self.weapon ), self.grab_target:GetOrigin(), self.rate ) --   + self.grab_target:GetOrigin() - self.grab_target:GetCenter()
	
	self.grab_target:SetOrigin( newOrigin )
	self.grab_target:SetAngles( target_qangles[1], target_qangles[2], target_qangles[3] )

end

function grabmodifier:OnAttackLanded( params )
	if IsClient() then return end

	if params.attacker ~= self:GetParent() then return end -- do nothing
	
	local nTargetFX = ParticleManager:CreateParticle( "particles/custom/silencer_global_silence_dust_hit.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetCaster() )
	ParticleManager:SetParticleControlEnt( nTargetFX, 1, params.target, PATTACH_ABSORIGIN_FOLLOW, nil, params.target:GetAbsOrigin(), false )
	ParticleManager:ReleaseParticleIndex( nTargetFX )
	
	if self:GetCaster():HasScepter() then
		if params.target ~= nil and params.target:GetTeamNumber() ~= self:GetParent():GetTeamNumber() then
			local cleaveDamage = ( self.cleave_percentage * params.damage ) / 100.0
			DoCleaveAttack( self:GetParent(), params.target, self:GetAbility(), cleaveDamage, 40.0, self.cleave_rad, self.cleave_rad, "particles/units/heroes/hero_sven/sven_spell_great_cleave.vpcf" )
		end
	end
	
	local dm = math.max( 0, params.target:GetPhysicalArmorValue( false ) ) * 2.0
	if dm > 0 then
		local damage = {
					victim = self.grab_target,
					attacker = self:GetCaster(),
					damage = dm,
					damage_type = DAMAGE_TYPE_PHYSICAL,		
					ability = self:GetAbility()
				}

		ApplyDamage( damage )
	end
	
	if self.grab_target:IsBuilding() then
		local sounds = 
		{
			"tower_ouch_1",
			"tower_ouch_2"
		}
		
		self.grab_target:EmitSound(sounds[RandomInt(1, #sounds)])
	else

		local sounds = 
		{
			"ouch_1",
			"ouch_2",
			"ouch_3",
			"ouch_4"
		}
		
		self.grab_target:EmitSound(sounds[RandomInt(1, #sounds)])
	end
end

function grabmodifier:OnAttack( params )
	if IsClient() then return end
	
	if params.attacker ~= self:GetParent() then return end -- do nothing
	
	if not self:GetCaster():HasScepter() then
		self:DecrementStackCount()
		
		
		if self:GetStackCount() == 0 then
		--[[
			local aimPos = self:GetCursorPosition()
			local tossStartPos = target:GetOrigin()
			local caster = self:GetCaster()
			
			local mod = target:AddNewModifier(
								caster,
								self,
								"beingtossedmodifier",
								{
									tossPointX = aimPos.x, 
									tossPointY = aimPos.y, 
									tossPointZ = aimPos.z,
									tossFromX = tossStartPos.x, 
									tossFromY = tossStartPos.y, 
									tossFromZ = tossStartPos.z,
									duration = dur,
									damage = dam,
									range = ran,
								}
			)
			
			if mod == nil then
				print( "failed to add beingtossedmodifier" )
			end
			
			caster:EmitSound("throw_1")
			]]--
			self:Destroy()
		end
	end
end

function grabmodifier:DeclareFunctions()
	if IsClient() then return end
	
	local funcs = {
		MODIFIER_PROPERTY_MOVESPEED_BONUS_PERCENTAGE,
		MODIFIER_PROPERTY_BASEATTACK_BONUSDAMAGE,
		MODIFIER_PROPERTY_TURN_RATE_PERCENTAGE,
		MODIFIER_EVENT_ON_ATTACK_LANDED,
		MODIFIER_EVENT_ON_ATTACK,
	}

	return funcs
end

function grabmodifier:GetModifierMoveSpeedBonus_Percentage( params )
	if IsClient() then return 0 end
	return -self.move_slow_rate
end

function grabmodifier:GetModifierTurnRate_Percentage( params )
	if IsClient() then return 0 end
	return -self.turn_rate
end

function grabmodifier:GetModifierBaseAttack_BonusDamage( params )
	if IsClient() then return 0 end
	return self.grab_target:GetHealth() * self.damage_increase / 100.0
end
