
parentedmodifier = class({})

function parentedmodifier:RemoveOnDeath() return true end
function parentedmodifier:IsPurgable() return false end
function parentedmodifier:IsPurgeException() return false end
function parentedmodifier:IsHidden() return true end 	-- we can hide the modifier

function parentedmodifier:GetAttributes()
	return self.BaseClass.GetAttributes( self )
		+ MODIFIER_ATTRIBUTE_PERMANENT           -- Modifier passively remains until strictly removed. 
		+ MODIFIER_ATTRIBUTE_IGNORE_INVULNERABLE -- Allows modifier to be assigned to invulnerable entities. 
end

function parentedmodifier:AddParent()
	local newAngles = self.grab_target:GetAngles()
	self.grab_target.parent:SetAngles( newAngles[1], newAngles[2], newAngles[3] )
	self.grab_target.parent:SetOrigin( self.grab_target:GetCenter() )
	self.grab_target:SetParent( self.grab_target.parent, "" )
	
	self.grab_target.GetAngles = function( this ) return this.parent:GetAngles() end
	self.grab_target.SetAngles = function( this, x, y ,z ) return this.parent:SetAngles( x, y, z ) end
	self.grab_target.GetOrigin = function( this ) return this.parent:GetOrigin() end
	self.grab_target.GetAbsOrigin = function( this ) return this.parent:GetAbsOrigin() end
	self.grab_target.SetAbsOrigin = function( this, vec ) return this.parent:SetAbsOrigin( vec ) end
	self.grab_target.SetOrigin = function( this, vec ) return this.parent:SetOrigin( vec ) end
	self.grab_target.GetCenter = function( this ) return this.parent:GetCenter() end
	self.grab_target.GetAttachmentOrigin = function( this, iAtt ) return this.parent:GetOrigin() end
	
	self.grab_target.animation = ACT_DOTA_FLAIL
	self.grab_target:StartGestureWithPlaybackRate( self.grab_target.animation, 1.5 )
end

function parentedmodifier:OnCreated( kv )
	if IsClient() then return end
	
	self.grab_target = self:GetParent()
	
	self.grabbed_by_ally = (self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber())
	
	-- backup methods
	self.old_GetAngles = self.grab_target.GetAngles
	self.old_SetAngles = self.grab_target.SetAngles
	self.old_GetOrigin = self.grab_target.GetOrigin
	self.old_GetAbsOrigin = self.grab_target.GetAbsOrigin
	self.old_SetAbsOrigin = self.grab_target.SetAbsOrigin
	self.old_SetOrigin = self.grab_target.SetOrigin
	self.old_GetCenter = self.grab_target.GetCenter
	self.old_GetAttachmentOrigin = self.grab_target.GetAttachmentOrigin
	--
	
	self.grab_target.parent = CreateUnitByName("npc_dota_creature_building_parent", self.grab_target:GetCenter(), false, self.grab_target, self.grab_target, self.grab_target:GetTeamNumber())
	self.grab_target.parent:AddNewModifier(self.grab_target.parent, nil, "modifier_out_of_game", {})
	
	self:AddParent()

	
end

function parentedmodifier:OnRefresh( kv )
	if IsClient() then return end
	
	self.grabbed_by_ally = (self:GetCaster():GetTeamNumber() == self:GetParent():GetTeamNumber())
	
	if self.grab_target.animation ~= ACT_DOTA_FLAIL then
		self.grab_target:RemoveGesture( self.grab_target.animation )
		
		self:AddParent()
	end
	
end

function parentedmodifier:RemoveParent()
	self.grab_target:RemoveGesture( self.grab_target.animation )
	
	-- return backup methods
	self.grab_target.GetAngles = self.old_GetAngles
	self.grab_target.SetAngles = self.old_SetAngles
	self.grab_target.GetOrigin = self.old_GetOrigin
	self.grab_target.GetAbsOrigin = self.old_GetAbsOrigin
	self.grab_target.SetAbsOrigin = self.old_SetAbsOrigin
	self.grab_target.SetOrigin = self.old_SetOrigin
	self.grab_target.GetCenter = self.old_GetCenter
	self.grab_target.GetAttachmentOrigin = self.old_GetAttachmentOrigin
	--
	
	self.grab_target:SetParent( nil, nil )
	
	local angles = self.grab_target:GetAngles()
	self.grab_target:SetAngles( 0, angles[2], 0 ) -- fix rotation
	self.grab_target:SetOrigin( GetGroundPosition( self.grab_target.parent:GetOrigin(), self.grab_target ) )
end

function parentedmodifier:OnDestroy()
	if IsClient() then return end
	
	self:RemoveParent()
	
	ResolveNPCPositions( self.grab_target:GetOrigin(), 100 )
	
	FindClearSpaceForUnit( self.grab_target, self.grab_target:GetOrigin(), true )
	
	self.grab_target.parent:Destroy()
	self.grab_target.parent = nil
	
	if not self.grab_target:HasModifier( "getsmackedmodifier" ) then
		self.grab_target:AddNewModifier( self:GetCaster(), self:GetAbility(), "getsmackedmodifier", {} )
	end
end

function parentedmodifier:CheckState()
	if IsClient() then return 0 end
	
	local state = {
		[MODIFIER_STATE_NO_UNIT_COLLISION] = true,
		[MODIFIER_STATE_ROOTED] = true,
		[MODIFIER_STATE_ATTACK_IMMUNE] = true,
		[MODIFIER_STATE_DISARMED] = true,
	}

	return state
end
