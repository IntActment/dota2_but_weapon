modifier_tower_invulnerable_butt = class({})

LinkLuaModifier("modifier_tower_invulnerable_butt", "internal/modifier_tower_invulnerable_butt", LUA_MODIFIER_MOTION_NONE)
if IsClient() then return end

function modifier_tower_invulnerable_butt:IsPermanent() return true end
function modifier_tower_invulnerable_butt:IsDebuff() return false end


function modifier_tower_invulnerable_butt:OnCreated(event)
	print( "modifier_tower_invulnerable_butt:OnCreated" )
end

function modifier_tower_invulnerable_butt:OnIntervalThink()
end

function modifier_tower_invulnerable_butt:CheckState()
	return {
		[MODIFIER_STATE_INVULNERABLE] =  true,
		[MODIFIER_STATE_NO_TEAM_SELECT] =  true,
		[MODIFIER_STATE_NO_HEALTH_BAR] =  true,
	}
end
