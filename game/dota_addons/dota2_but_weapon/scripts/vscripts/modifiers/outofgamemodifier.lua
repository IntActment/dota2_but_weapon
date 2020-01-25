
outofgamemodifier = class({})

function outofgamemodifier:RemoveOnDeath() return true end
function outofgamemodifier:IsPurgable() return false end
function outofgamemodifier:IsPurgeException() return false end
function outofgamemodifier:IsHidden() return true end 	-- we can hide the modifier


function outofgamemodifier:GetAttributes()
	return self.BaseClass.GetAttributes( self )
		+ MODIFIER_ATTRIBUTE_PERMANENT
		+ MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE -- Allows modifier to be assigned to invulnerable entities. 
end

function outofgamemodifier:OnCreated( kv )
	if IsClient() then return end
	
	local pos = self:GetParent():GetAbsOrigin()
	pos[3] = -200
	
	self:GetParent():SetAbsOrigin( pos )
	
	self:StartIntervalThink( 1 )
	
	
end

function outofgamemodifier:OnIntervalThink()
	if IsClient() then return end
	
	local mods = self:GetParent():FindAllModifiers()
	for _,mod in pairs(mods) do
		
		if mod ~= self then
			--print( "mod destroyed: " .. mod:GetClass() )
			mod:Destroy()
		end
	end
	
	self:StartIntervalThink( -1 )
end

function outofgamemodifier:CheckState()
	local state = {
		[MODIFIER_STATE_OUT_OF_GAME] = true,
		[MODIFIER_STATE_NO_HEALTH_BAR] = true,
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_INVULNERABLE] = true,
		[MODIFIER_STATE_DISARMED] = true,
		[MODIFIER_STATE_TRUESIGHT_IMMUNE] = true,
		[MODIFIER_STATE_INVISIBLE] = true,
	}

	return state
end