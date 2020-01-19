tossnpcability = class({})

function tossnpcability:IsStealable() return false end

function tossnpcability:OnAbilityPhaseStart()
	self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_CAST_ABILITY_1, 1.0 )
	return true
end

function tossnpcability:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
end

function tossnpcability:CastFilterResultLocation( vLoc )
	if IsClient() then return UF_SUCCESS end

	-- register cursor position
	self.aimPos = vLoc

	return UF_SUCCESS
end

function tossnpcability:OnSpellStart()
	if IsClient() then return end
	
	self:GetCaster():RemoveGesture( ACT_DOTA_CAST_ABILITY_1 )
	
	local dam = self:GetSpecialValueFor( "damage" )
	local ran = self:GetSpecialValueFor( "range" )
	local aimPos = self:GetCursorPosition()
	local caster = self:GetCaster()
	
	local g_modifier = caster:FindModifierByName("grabmodifier")
	
	if g_modifier ~= nil then
		
		local dur = 0.75
		local target = g_modifier.grab_target
		
		g_modifier:Destroy()
		
		local tossStartPos = target:GetOrigin()
		
		target:Interrupt()
		
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
		
	end
	
end

LinkLuaModifier( "beingtossedmodifier", "modifiers/beingtossedmodifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "getsmackedmodifier", "modifiers/getsmackedmodifier", LUA_MODIFIER_MOTION_NONE )