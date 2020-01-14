

beinggrabbedmodifier = beinggrabbedmodifier or class({})

function beinggrabbedmodifier:GetTexture() return "custom_grabmodifier" end

function beinggrabbedmodifier:OnCreated( kv )
	if IsClient() then return end
	
	-- we have to read the "duration" number from the AddNewModifer(..) to use it.
	self.duration = kv.duration
	self.grabbed_by_ally = kv.ally
	
	self:GetParent():AddNewModifier( self:GetCaster(), self:GetAbility(), "parentedmodifier", {} )

end


function beinggrabbedmodifier:OnDestroy()
	if IsClient() then return end

	-- unset
	local grab_target = self:GetParent()
	
	if self:GetCaster():IsAlive() then
		self:GetCaster():RemoveModifierByName("grabmodifier")
	end
end

function beinggrabbedmodifier:RemoveOnDeath() return true end
function beinggrabbedmodifier:IsHidden() return false end 	-- we can hide the modifier
function beinggrabbedmodifier:IsDebuff() return true end 	-- make it red or green
function beinggrabbedmodifier:DestroyOnExpire() return true end
function beinggrabbedmodifier:IsStunDebuff() return true end
function beinggrabbedmodifier:IsPurgable() return false end

function beinggrabbedmodifier:DeclareFunctions()
	if IsClient() then return {} end
	
	return {
		--MODIFIER_EVENT_ON_ATTACK_LANDED, -- OnAttackLanded (check the link below)
		-- MODIFIER_EVENT_ON_TELEPORTED, -- OnTeleported 
		-- MODIFIER_PROPERTY_MANA_BONUS, -- GetModifierManaBonus 

		
		-- can contain everything from the API
		-- https://developer.valvesoftware.com/wiki/Dota_2_Workshop_Tools/Scripting/API

	}
end
