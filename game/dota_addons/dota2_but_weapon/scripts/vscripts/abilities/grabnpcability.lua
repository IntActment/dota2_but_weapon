
local function print_r ( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end


-------------------------------------------------------------------------------------------------------------------------------

local butts = BUTTINGS

grabnpcability = class({})

function grabnpcability:OnAbilityPhaseStart()
	self:GetCaster():StartGestureWithPlaybackRate( ACT_DOTA_ATTACK2, 1.0 )
	return true
end

function grabnpcability:OnAbilityPhaseInterrupted()
	self:GetCaster():RemoveGesture( ACT_DOTA_ATTACK2 )
end

function grabnpcability:IsStealable() return false end

function grabnpcability:GetCastRange( vLocation, hTarget )
	return self:GetSpecialValueFor( "grab_rad" )
end

function grabnpcability:CanAbilityBeUpgraded() return true end

function grabnpcability:OnSpellStart()
	if IsClient() then return end	
	
	self:GetCaster():RemoveGesture( ACT_DOTA_ATTACK2 )
	
	--reading the values from the kv file
	local grab_duration_basic = self:GetSpecialValueFor( "duration" )
	local slow = self:GetSpecialValueFor( "move_slow_rate" )
	local turn = self:GetSpecialValueFor( "turn_rate" )
	local grab_radius = self:GetSpecialValueFor( "grab_rad" )
	local cleave_rad = self:GetSpecialValueFor( "cleave_rad" )
	local cleave_percentage = self:GetSpecialValueFor( "cleave_percentage" )
	local stack_limit = self:GetSpecialValueFor( "stack_limit" )
	local damage_increase = self:GetSpecialValueFor( "damage_increase" )	
	local break_distance = self:GetSpecialValueFor( "break_distance" )	
	
	-- remove old grabber state

	self.grab_target:RemoveModifierByName("beinggrabbedmodifier")

	local isAlly = (self:GetCaster():GetTeamNumber() == self.grab_target:GetTeamNumber())
	if isAlly then
		grab_duration_basic = self:GetSpecialValueFor( "duration_ally" )
	end
	
	--local mods = self.grab_target:FindAllModifiers()
	--print( "modifiers on " .. self.grab_target:GetName() .. ":" )
	--for k,v in pairs(mods) do
	--	print( "- " .. v:GetName() )
	--end
	
	self.grab_target:Interrupt()

	-- now we add a modifier to the caster, that makes him grabbing the foe
	self:GetCaster():AddNewModifier(
		self:GetCaster(),
		self,
		"grabmodifier",
		{
			duration = grab_duration_basic,
			targetID = self.grab_target:GetEntityIndex(),
			move_slow_rate = slow,
			turn_rate = turn,
			cl_rad = cleave_rad,
			cl_percentage = cleave_percentage,
			st_limit = stack_limit,
			dam_increase = damage_increase,
			br_distance = break_distance
		}
	)
end

function grabnpcability:CastFilterResultTarget( hTarget )
	
	if IsClient() then return UF_SUCCESS end
	
	local caster = self:GetCaster()
	caster:RemoveGesture( ACT_DOTA_ATTACK2 )
	
	self.grab_target = hTarget
	self.grab_result = 0
	
	if self.grab_target == caster then
		self.grab_result = 1
		return UF_FAIL_CUSTOM
	elseif self.grab_target:IsFort() then
		self.grab_result = 2
		return UF_FAIL_CUSTOM
	elseif butts.CanGrabAllyFountain() or butts.CanGrabAnyFountain() then
		local team = -1
		if hTarget:GetName() == "ent_dota_fountain_good" then
			team = DOTA_TEAM_GOODGUYS
		elseif hTarget:GetName() == "ent_dota_fountain_bad" then
			team = DOTA_TEAM_BADGUYS
		end
		
		if team ~= -1 then
			-- its a fountain
			if butts.CanGrabAllyFountain() and team ~= caster:GetTeamNumber() then
				-- cannot grab enemy fountain
				self.grab_result = 3
				return UF_FAIL_CUSTOM
			end
		end
	end

	return UF_SUCCESS
end

function grabnpcability:GetCustomCastErrorTarget( hTarget )

	if self.grab_result == 1 then
		return "You can not grab yourself!"
	elseif self.grab_result == 2 then
		return "You can not grab the ancient!"
	elseif self.grab_result == 3 then
		return "You can not grab enemy fountain!"
	end

	return "I'm bored to do this"
end

-------------------------------------------------------------------------------------------------------------------------------
LinkLuaModifier( "grabmodifier", "modifiers/grabmodifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "beinggrabbedmodifier", "modifiers/beinggrabbedmodifier", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "modifier_out_of_game", "modifiers/modifier_out_of_game", LUA_MODIFIER_MOTION_NONE )
LinkLuaModifier( "parentedmodifier", "modifiers/parentedmodifier", LUA_MODIFIER_MOTION_NONE  )
LinkLuaModifier( "getsmackedmodifier", "modifiers/getsmackedmodifier", LUA_MODIFIER_MOTION_NONE )
