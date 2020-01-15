local Thinker = class({})

ListenToGameEvent("game_rules_state_game_in_progress", function()
		Timers:CreateTimer( 0, Thinker.Minute00 )
		Timers:CreateTimer( 20*60, Thinker.DontForgetToSubscribe )
		Timers:CreateTimer( 30*60, Thinker.LateGame )
		Timers:CreateTimer( Thinker.VeryVeryOften )
		Timers:CreateTimer( Thinker.VeryOften )
		Timers:CreateTimer( Thinker.Often )
		Timers:CreateTimer( Thinker.Regular )
		Timers:CreateTimer( Thinker.Seldom )
end, GameMode)

killedBuildings = killedBuildings or {}

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

local conds = {
	bad_filler_1 = cond_bad_t4,
	bad_filler_2 = cond_bad_t4,
	bad_filler_3 = cond_bad_t4,
	bad_filler_4 = cond_bad_t4,
	bad_filler_5 = cond_bad_t4,
	bad_filler_6 = cond_bad_t4,
	bad_filler_7 = cond_bad_t4,
	bad_healer_7 = cond_bad_t4,
	bad_rax_melee_bot = cond_bad_rax_bot,
	bad_rax_melee_mid = cond_bad_rax_mid,
	bad_rax_melee_top = cond_bad_rax_top,
	bad_rax_range_bot = cond_bad_rax_bot,
	bad_rax_range_mid = cond_bad_rax_mid,
	bad_rax_range_top = cond_bad_rax_top,
	dota_badguys_fort = cond_bad_ancient,
	dota_badguys_tower1_bot = function() return true end,
	dota_badguys_tower1_mid = function() return true end,
	dota_badguys_tower1_top = function() return true end,
	dota_badguys_tower2_bot = cond_bad_t2_bot,
	dota_badguys_tower2_mid = cond_bad_t2_mid,
	dota_badguys_tower2_top = cond_bad_t2_top,
	dota_badguys_tower3_bot = cond_bad_t3_bot,
	dota_badguys_tower3_mid = cond_bad_t3_mid,
	dota_badguys_tower3_top = cond_bad_t3_top,
	dota_badguys_tower4_bot = cond_bad_t4,
	dota_badguys_tower4_top = cond_bad_t4,
	dota_goodguys_fort = cond_good_ancient,
	dota_goodguys_tower1_bot = function() return true end,
	dota_goodguys_tower1_mid = function() return true end,
	dota_goodguys_tower1_top = function() return true end,
	dota_goodguys_tower2_bot = cond_good_t2_bot,
	dota_goodguys_tower2_mid = cond_good_t2_mid,
	dota_goodguys_tower2_top = cond_good_t2_top,
	dota_goodguys_tower3_bot = cond_good_t3_bot,
	dota_goodguys_tower3_mid = cond_good_t3_mid,
	dota_goodguys_tower3_top = cond_good_t3_top,
	dota_goodguys_tower4_bot = cond_good_t4,
	dota_goodguys_tower4_top = cond_good_t4,
	good_filler_1 = cond_good_t4,
	good_filler_2 = cond_good_t4,
	good_filler_3 = cond_good_t4,
	good_filler_4 = cond_good_t4,
	good_filler_5 = cond_good_t4,
	good_filler_6 = cond_good_t4,
	good_filler_7 = cond_good_t4,
	good_healer_6 = cond_good_t4,
	good_rax_melee_bot = cond_good_rax_bot,
	good_rax_melee_mid = cond_good_rax_mid,
	good_rax_melee_top = cond_good_rax_top,
	good_rax_range_bot = cond_good_rax_bot,
	good_rax_range_mid = cond_good_rax_mid,
	good_rax_range_top = cond_good_rax_top,
}

function FillTowerKillConds()

	for buildingName,cont in pairs(conds) do
		local hBuilding = Entities:FindByName( nil, buildingName )
		
		if hBuilding == nil then		
			print( "building \"" .. buildingName .. "\" was not found" )
		else
			print("removed invul from " .. hBuilding:GetName())
			hBuilding:SetInvulnCount( 0 )
			
			hBuilding.canBeDamagedByHero = cont
		end
	end
	
end

function Thinker:Minute00()
	print("The Game begins!")
	
	FillTowerKillConds()

--[[
	local hBuildings = FindUnitsInRadius(DOTA_TEAM_NOTEAM,
					  Vector(0, 0, 0),
					  nil,
					  FIND_UNITS_EVERYWHERE,
					  DOTA_UNIT_TARGET_TEAM_BOTH,
					  DOTA_UNIT_TARGET_BUILDING,
					  DOTA_UNIT_TARGET_FLAG_INVULNERABLE,
					  FIND_ANY_ORDER,
					  false)

	for _,hBuilding in pairs(hBuildings) do
		if hBuilding:IsTower() or hBuilding:IsBarracks() or hBuilding:IsShrine() or string.match(hBuilding:GetName(), "healer") then
		
			print(hBuilding:GetName())
			hBuilding:SetInvulnCount( 0 )
			
			hBuilding.isInvul = true
			
		end
	end
	]]--

	return nil -- does not repeat
end

function Thinker:DontForgetToSubscribe()
	-- print("20 minutes")
	return nil -- does not repeat
end

function Thinker:LateGame()
	-- print("30 minutes")
	return nil -- does not repeat
end

function Thinker:VeryVeryOften()
	-- print("every 10 seconds")
	return 10
end

function Thinker:VeryOften()
	-- print("every minute")
	return 1*60
end

function Thinker:Often()
	-- print("every 5 minutes")
	return 5*60
end

function Thinker:Regular()
	-- print("every 15 minutes")
	return 15*60
end

function Thinker:Seldom()
	-- print("every 30 minutes")
	return 30*60
end
