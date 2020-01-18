


getsmackedmodifier = class({})

function getsmackedmodifier:GetTexture() return "custom_getsmackedmodifier" end

function getsmackedmodifier:RemoveOnDeath() return true end
function getsmackedmodifier:IsPurgable() return false end
function getsmackedmodifier:IsPurgeException() return true end
function getsmackedmodifier:DestroyOnExpire() return true end
function getsmackedmodifier:IsHidden() return true end
function getsmackedmodifier:IsDebuff() return true end
function getsmackedmodifier:IsStunDebuff() return true end

function getsmackedmodifier:GetAttributes()
	return self.BaseClass.GetAttributes( self )
		+ MODIFIER_ATTRIBUTE_PERMANENT           -- Modifier passively remains until strictly removed. 
end

function getsmackedmodifier:OnCreated( kv )
	if IsClient() then return end
	
	self.stunned = true
	self.grab_target = self:GetParent()
	
	self:SetDuration( 2.5, false )
	
	self.grab_target:RemoveGesture( ACT_DOTA_FLAIL )
	self.grab_target:StartGestureWithPlaybackRate( ACT_DOTA_DIE, 1.0 )
	
	self.grab_target:EmitSound("drop_1")

end

function getsmackedmodifier:OnRefresh( kv )
	if IsClient() then return end	
	
	self.stunned = true
	self.grab_target = self:GetParent()
	
	self:SetDuration( 2.5, false )
	
	self.grab_target:RemoveGesture( ACT_DOTA_FLAIL )
	self.grab_target:StartGestureWithPlaybackRate( ACT_DOTA_DIE, 1.0 )
	
	self.grab_target:EmitSound("drop_1")
end

function getsmackedmodifier:OnDestroy()
	if IsClient() then return end
	
	self.grab_target:RemoveGesture( ACT_DOTA_DIE )
	
end

function getsmackedmodifier:CheckState()
	local state = {
		[MODIFIER_STATE_STUNNED] = self.stunned,
	}

	return state
end

function getsmackedmodifier:GetEffectName()
	return "particles/generic_gameplay/generic_stunned.vpcf"
end

function getsmackedmodifier:GetEffectAttachType()
	return PATTACH_OVERHEAD_FOLLOW
end

function getsmackedmodifier:CheckState()
	if IsClient() then return 0 end
	
	local state = {
		[MODIFIER_STATE_MUTED] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_STUNNED] = true
	}

	return state
end

