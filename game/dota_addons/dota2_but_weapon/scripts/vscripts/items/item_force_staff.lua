
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

---------------------------------------------------------------------------------------------

function ForceStaff (keys)
	if IsClient() then return end
	
	--print( "ForceStaff" )	
	--print_r( keys )

	local target = keys.caster
	local ability = keys.ability
	local ability_level = ability:GetLevel() - 1	

	target:Stop()

	ability.forced_direction = target:GetForwardVector()
	ability.forced_distance = ability:GetLevelSpecialValueFor("push_length", ability_level)
	ability.forced_speed = ability:GetLevelSpecialValueFor("push_speed", ability_level) * 1 / 30.0	-- * 1/30 gives a duration of ~0.4 second push time (which is what the gamepedia-site says it should be)
	ability.forced_traveled = 0

end

function ForceHorizontal( keys )
	if IsClient() then return end

	--print( "ForceHorizontal" )	
	--print_r( keys )
	
	local target = keys.caster
	local ability = keys.ability

	if ability.forced_traveled < ability.forced_distance then
		target:SetAbsOrigin(target:GetAbsOrigin() + ability.forced_direction * ability.forced_speed)
		ability.forced_traveled = ability.forced_traveled + (ability.forced_direction * ability.forced_speed):Length2D()
	else
		target:InterruptMotionControllers(true)
	end

end