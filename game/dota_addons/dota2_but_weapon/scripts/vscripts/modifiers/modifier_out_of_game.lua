modifier_out_of_game = modifier_out_of_game or class({})

function modifier_out_of_game:RemoveOnDeath() return false end
function modifier_out_of_game:IsHidden() return true end
function modifier_out_of_game:IsPurgable() return false end
function modifier_out_of_game:IsPurgeException() return false end


function modifier_out_of_game:GetAttributes()
	return 0
		+ MODIFIER_ATTRIBUTE_PERMANENT           -- Modifier passively remains until strictly removed. 
		+ MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE -- Allows modifier to be assigned to invulnerable entities. 
end

function modifier_out_of_game:CheckState()
	return {
 		[MODIFIER_STATE_UNSELECTABLE] =  true,
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_MAGIC_IMMUNE] = true,
		[MODIFIER_STATE_NOT_ON_MINIMAP] = true,
	}
end
