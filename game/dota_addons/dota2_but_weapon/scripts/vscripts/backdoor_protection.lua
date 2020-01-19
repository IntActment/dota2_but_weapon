
local backdoor_protection = class ({})

LinkLuaModifier("travelmodifier", "modifiers/travelmodifier", LUA_MODIFIER_MOTION_NONE)

local killedBuildings = {}

-- Listen to game starting event
ListenToGameEvent("game_rules_state_game_in_progress", function()
		Timers:CreateTimer( 0, backdoor_protection.OnGameStarted )
end, GameMode)

-- Listen to damage filter
ListenToGameEvent("addon_game_mode_activate",function()
	local contxt = {}
	GameRules:GetGameModeEntity():SetDamageFilter( backdoor_protection.DamageFilter, contxt )
end, nil)

ListenToGameEvent("entity_killed", function(keys)
	local killedUnit = keys.entindex_killed and EntIndexToHScript(keys.entindex_killed)
	
	if (killedUnit and killedUnit:IsBuilding()) then
		killedBuildings[killedUnit:GetName()] = true
	end

end, nil)


local cond_bad_ancient = function() return killedBuildings["dota_badguys_tower4_bot"] and killedBuildings["dota_badguys_tower4_top"] end
local cond_good_ancient = function() return killedBuildings["dota_goodguys_tower4_bot"] and killedBuildings["dota_goodguys_tower4_top"] end

local cond_bad_t4 = function() return killedBuildings["dota_badguys_tower3_bot"] or killedBuildings["dota_badguys_tower3_mid"] or killedBuildings["dota_badguys_tower3_top"] end
local cond_good_t4 = function() return killedBuildings["dota_goodguys_tower3_bot"] or killedBuildings["dota_goodguys_tower3_mid"] or killedBuildings["dota_goodguys_tower3_top"] end

local cond_bad_rax_bot = function() return killedBuildings["dota_badguys_tower3_bot"] end
local cond_bad_rax_mid = function() return killedBuildings["dota_badguys_tower3_mid"] end
local cond_bad_rax_top = function() return killedBuildings["dota_badguys_tower3_top"] end

local cond_good_rax_bot = function() return killedBuildings["dota_goodguys_tower3_bot"] end
local cond_good_rax_mid = function() return killedBuildings["dota_goodguys_tower3_mid"] end
local cond_good_rax_top = function() return killedBuildings["dota_goodguys_tower3_top"] end

local cond_bad_t3_bot = function() return killedBuildings["dota_badguys_tower2_bot"] end
local cond_bad_t3_mid = function() return killedBuildings["dota_badguys_tower2_mid"] end
local cond_bad_t3_top = function() return killedBuildings["dota_badguys_tower2_top"] end

local cond_good_t3_bot = function() return killedBuildings["dota_goodguys_tower2_bot"] end
local cond_good_t3_mid = function() return killedBuildings["dota_goodguys_tower2_mid"] end
local cond_good_t3_top = function() return killedBuildings["dota_goodguys_tower2_top"] end

local cond_bad_t2_bot = function() return killedBuildings["dota_badguys_tower1_bot"] end
local cond_bad_t2_mid = function() return killedBuildings["dota_badguys_tower1_mid"] end
local cond_bad_t2_top = function() return killedBuildings["dota_badguys_tower1_top"] end

local cond_good_t2_bot = function() return killedBuildings["dota_goodguys_tower1_bot"] end
local cond_good_t2_mid = function() return killedBuildings["dota_goodguys_tower1_mid"] end
local cond_good_t2_top = function() return killedBuildings["dota_goodguys_tower1_top"] end

local cond_bad_t1_bot = function() return true end
local cond_bad_t1_mid = function() return true end
local cond_bad_t1_top = function() return true end

local cond_good_t1_bot = function() return true end
local cond_good_t1_mid = function() return true end
local cond_good_t1_top = function() return true end

backdoor_protection.props = {
	bad_filler_1 = { condition = cond_bad_t4, hasBackdoorProtection = true },
	bad_filler_2 = { condition = cond_bad_t4, hasBackdoorProtection = true },
	bad_filler_3 = { condition = cond_bad_t4, hasBackdoorProtection = true },
	bad_filler_4 = { condition = cond_bad_t4, hasBackdoorProtection = true },
	bad_filler_5 = { condition = cond_bad_t4, hasBackdoorProtection = true },
	bad_filler_6 = { condition = cond_bad_t4, hasBackdoorProtection = true },
	bad_filler_7 = { condition = cond_bad_t4, hasBackdoorProtection = true },
	bad_healer_7 = { condition = cond_bad_t4, hasBackdoorProtection = true },
	bad_rax_melee_bot = { condition = cond_bad_rax_bot, hasBackdoorProtection = true, range = 2000 },
	bad_rax_melee_mid = { condition = cond_bad_rax_mid, hasBackdoorProtection = true, range = 2000 },
	bad_rax_melee_top = { condition = cond_bad_rax_top, hasBackdoorProtection = true, range = 2000 },
	bad_rax_range_bot = { condition = cond_bad_rax_bot, hasBackdoorProtection = true, range = 2000 },
	bad_rax_range_mid = { condition = cond_bad_rax_mid, hasBackdoorProtection = true, range = 2000 },
	bad_rax_range_top = { condition = cond_bad_rax_top, hasBackdoorProtection = true, range = 2000 },
	dota_badguys_fort = { condition = cond_bad_ancient, hasBackdoorProtection = true, range = 2000 },
	dota_badguys_tower1_bot = { condition = cond_bad_t1_bot, hasBackdoorProtection = false, range = 3000 },
	dota_badguys_tower1_mid = { condition = cond_bad_t1_mid, hasBackdoorProtection = false, range = 3000 },
	dota_badguys_tower1_top = { condition = cond_bad_t1_top, hasBackdoorProtection = false, range = 3000 },
	dota_badguys_tower2_bot = { condition = cond_bad_t2_bot, hasBackdoorProtection = true, range = 2500 },
	dota_badguys_tower2_mid = { condition = cond_bad_t2_mid, hasBackdoorProtection = true, range = 2500 },
	dota_badguys_tower2_top = { condition = cond_bad_t2_top, hasBackdoorProtection = true, range = 2500 },
	dota_badguys_tower3_bot = { condition = cond_bad_t3_bot, hasBackdoorProtection = true, range = 2000 },
	dota_badguys_tower3_mid = { condition = cond_bad_t3_mid, hasBackdoorProtection = true, range = 2000 },
	dota_badguys_tower3_top = { condition = cond_bad_t3_top, hasBackdoorProtection = true, range = 2000 },
	dota_badguys_tower4_bot = { condition = cond_bad_t4, hasBackdoorProtection = true, range = 1000 },
	dota_badguys_tower4_top = { condition = cond_bad_t4, hasBackdoorProtection = true, range = 1000 },	
	
	good_filler_1 = { condition = cond_good_t4, hasBackdoorProtection = true },
	good_filler_2 = { condition = cond_good_t4, hasBackdoorProtection = true },
	good_filler_3 = { condition = cond_good_t4, hasBackdoorProtection = true },
	good_filler_4 = { condition = cond_good_t4, hasBackdoorProtection = true },
	good_filler_5 = { condition = cond_good_t4, hasBackdoorProtection = true },
	good_filler_6 = { condition = cond_good_t4, hasBackdoorProtection = true },
	good_filler_7 = { condition = cond_good_t4, hasBackdoorProtection = true },
	good_healer_6 = { condition = cond_good_t4, hasBackdoorProtection = true },
	good_rax_melee_bot = { condition = cond_good_rax_bot, hasBackdoorProtection = true, range = 2000 },
	good_rax_melee_mid = { condition = cond_good_rax_mid, hasBackdoorProtection = true, range = 2000 },
	good_rax_melee_top = { condition = cond_good_rax_top, hasBackdoorProtection = true, range = 2000 },
	good_rax_range_bot = { condition = cond_good_rax_bot, hasBackdoorProtection = true, range = 2000 },
	good_rax_range_mid = { condition = cond_good_rax_mid, hasBackdoorProtection = true, range = 2000 },
	good_rax_range_top = { condition = cond_good_rax_top, hasBackdoorProtection = true, range = 2000 },
	dota_goodguys_fort = { condition = cond_good_ancient, hasBackdoorProtection = true },
	dota_goodguys_tower1_bot = { condition = cond_good_t1_bot, hasBackdoorProtection = false, range = 3000 },
	dota_goodguys_tower1_mid = { condition = cond_good_t1_mid, hasBackdoorProtection = false, range = 3000 },
	dota_goodguys_tower1_top = { condition = cond_good_t1_top, hasBackdoorProtection = false, range = 3000 },
	dota_goodguys_tower2_bot = { condition = cond_good_t2_bot, hasBackdoorProtection = true, range = 2500 },
	dota_goodguys_tower2_mid = { condition = cond_good_t2_mid, hasBackdoorProtection = true, range = 2500 },
	dota_goodguys_tower2_top = { condition = cond_good_t2_top, hasBackdoorProtection = true, range = 2500 },
	dota_goodguys_tower3_bot = { condition = cond_good_t3_bot, hasBackdoorProtection = true, range = 2000 },
	dota_goodguys_tower3_mid = { condition = cond_good_t3_mid, hasBackdoorProtection = true, range = 2000 },
	dota_goodguys_tower3_top = { condition = cond_good_t3_top, hasBackdoorProtection = true, range = 2000 },
	dota_goodguys_tower4_bot = { condition = cond_good_t4, hasBackdoorProtection = true, range = 1000 },
	dota_goodguys_tower4_top = { condition = cond_good_t4, hasBackdoorProtection = true, range = 1000 },
}

function backdoor_protection:OnGameStarted()
	print("backdoor_protection: game started")
	
	for buildingName,props in pairs(backdoor_protection.props) do
		local hBuilding = Entities:FindByName( nil, buildingName )
		
		if hBuilding == nil then		
			print( "backdoor_protection: building \"" .. buildingName .. "\" was not found" )
		else
			print("backdoor_protection: removed invul from " .. hBuilding:GetName())
			hBuilding:SetInvulnCount( 0 )
			
			-- replace base backdoor modifier with usual one
			if hBuilding:HasModifier( "modifier_backdoor_protection_in_base" ) then
				hBuilding:RemoveModifierByName( "modifier_backdoor_protection_in_base" )
				
				local mod = hBuilding:AddNewModifier(
							hBuilding,
							nil,
							"modifier_backdoor_protection",
							{}
				)
		
				if mod == nil then
					print( "failed to add modifier_backdoor_protection" )
				end
			end
			
			-- modifier_backdoor_protection_in_base
			-- modifier_backdoor_protection_active
			-- modifier_backdoor_protection
			
			hBuilding.canBeDamagedByHero = props.condition
			hBuilding.hasBackdoorProtection = props.hasBackdoorProtection
			
			-- let buildings tp back
			if props.range ~= nil then
				hBuilding:AddNewModifier( hBuilding, nil, "travelmodifier", { range = props.range } )
			end

		end
	end
	
	Timers:CreateTimer( 0, backdoor_protection.CheckRange )
	
	return nil -- does not repeat
end

function backdoor_protection:CheckRange()

	for buildingName,_ in pairs(backdoor_protection.props) do
		local hBuilding = Entities:FindByName( nil, buildingName )
		
		if hBuilding ~= nil and hBuilding:IsAlive() then
			if not hBuilding.hasBackdoorProtection then
				hBuilding:RemoveModifierByName( "modifier_backdoor_protection" )
				hBuilding:RemoveModifierByName( "modifier_backdoor_protection_active" )
			else		
				local units = FindUnitsInRadius( 
					hBuilding:GetTeamNumber(),
					hBuilding:GetAbsOrigin(),
					hBuilding,
					800,
					DOTA_UNIT_TARGET_TEAM_ENEMY,
					DOTA_UNIT_TARGET_CREEP,
					DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_NOT_ANCIENTS + DOTA_UNIT_TARGET_FLAG_NOT_DOMINATED + DOTA_UNIT_TARGET_FLAG_NOT_SUMMONED + DOTA_UNIT_TARGET_FLAG_NOT_ILLUSIONS,
					FIND_ANY_ORDER, 
					false )

				local isCreep = false
				for u,unit in pairs(units) do
					if not unit:IsNeutralUnitType() and unit:IsCreep() then
						--print( unit:GetName() .. " is a creep" )
						isCreep = true;
						break;
					end
				end
				
				if hBuilding:HasModifier( "modifier_backdoor_protection" ) and isCreep then
					hBuilding:RemoveModifierByName( "modifier_backdoor_protection" )
					hBuilding:RemoveModifierByName( "modifier_backdoor_protection_active" )
					--print("backdoor_protection: removed backdoor from " .. hBuilding:GetName())
				elseif not hBuilding:HasModifier( "modifier_backdoor_protection" ) and not isCreep then
					hBuilding:AddNewModifier(hBuilding, nil, "modifier_backdoor_protection_active", {})
					hBuilding:AddNewModifier(hBuilding, nil, "modifier_backdoor_protection", {})
					--print("backdoor_protection: added backdoor to " .. hBuilding:GetName())
				end
			end
		end
	end

	return 3.0 -- check interval
end

backdoor_protection.lastSay = Time();

function backdoor_protection:DamageFilter(event)
	-- PrintTable(event)
	local attackerUnit = event.entindex_attacker_const and EntIndexToHScript(event.entindex_attacker_const)
	local victimUnit = event.entindex_victim_const and EntIndexToHScript(event.entindex_victim_const)
	local damageType = event.damagetype_const
	local damage = event.damage -- can not get modified with local
	
	if victimUnit:IsBuilding() then
		if attackerUnit:IsBuilding() then
			--print( "Towers cannot damege each other" )
			
			--Say( victimUnit, "Towers cannot hit each other", false )
			
			return false
		end
		
		if attackerUnit:IsControllableByAnyPlayer() and ( victimUnit.canBeDamagedByHero ~= nil ) and ( not victimUnit.canBeDamagedByHero() ) then
			--print( "this tower cannot be attacked by any controllable unit" )
			if IsServer() then
				if ( not victimUnit:HasModifier( "beinggrabbedmodifier" ) )
					and ( not victimUnit:HasModifier( "beingtossedmodifier" ) )
					and ( not victimUnit:HasModifier( "getsmackedmodifier" ) ) then
					
					local now_time = Time()
					if now_time - backdoor_protection.lastSay > 2.0 then
						backdoor_protection.lastSay = now_time
						Say( victimUnit, "Only creeps can hurt me!", false )
					end
					
					local nTargetFX = ParticleManager:CreateParticle( "particles/units/heroes/hero_abaddon/abaddon_aphotic_shield_explosion.vpcf", PATTACH_ABSORIGIN_FOLLOW, victimUnit )
					ParticleManager:SetParticleControlEnt( nTargetFX, 1, victimUnit, PATTACH_ABSORIGIN_FOLLOW, nil, victimUnit:GetCenter(), false )
					ParticleManager:ReleaseParticleIndex( nTargetFX )
				end
			end
			
			return false
		end
	end

	return true
end