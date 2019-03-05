local Chaos = {}


Menu.AddMenuIcon({"Hero Specific", "Chaos Knight"}, "panorama/images/heroes/icons/npc_dota_hero_chaos_knight_png.vtex_c")
local MainOption = Menu.AddOptionBool({"Hero Specific", "Chaos Knight"}, "Reality Rift helper", false)
local Range = Menu.AddOptionSlider({"Hero Specific", "Chaos Knight"}, "Closest to mouse range", 50, 800, 300)
local Key = Menu.AddKeyOption({"Hero Specific", "Chaos Knight"}, "Reality Rift key", Enum.ButtonCode.KEY_F1)
local ComboKey = Menu.AddKeyOption({"Hero Specific", "Chaos Knight"}, "Combo key", Enum.ButtonCode.KEY_F2)

local My = {}
My.PrevCastTime = 0

function Chaos.OnUpdate()
	if not Menu.IsEnabled(MainOption) then
		return
	end
	if not My.Hero then
		My.Hero = Heroes.GetLocal()
		My.Player = Players.GetLocal()
		return
	end
	if not My.Name or not My.Team then
		My.Name = NPC.GetUnitName(My.Hero)
		My.Team = Entity.GetTeamNum(My.Hero)
		return
	end
	if My.Name ~= "npc_dota_hero_chaos_knight" then
		return
	end
	if not My.Rift or not Entity.IsAbility(My.Rift) then
		My.Rift = NPC.GetAbility(My.Hero, 'chaos_knight_reality_rift')
		return
	end

	if (Menu.IsKeyDown(Key) or Menu.IsKeyDown(ComboKey)) and Chaos.SleepReady(0.3, My.PrevCastTime) and Entity.IsAlive(My.Hero) and not NPC.IsSilenced(My.Hero) and not NPC.IsStunned(My.Hero)  then 
		local enemy = Input.GetNearestHeroToCursor(My.Team, Enum.TeamType.TEAM_ENEMY)
		if not enemy or enemy == 0 or not NPC.IsPositionInRange(enemy, Input.GetWorldCursorPos(), Menu.GetValue(Range)) then
			return
		end
		if Ability.IsReady(My.Rift) and Ability.IsCastable(My.Rift, NPC.GetMana(My.Hero)) then
			Ability.CastTarget(My.Rift, enemy)
		end
		Player.AttackTarget(My.Player, My.Hero, enemy)
		if NPC.HasModifier(enemy, 'modifier_chaos_knight_reality_rift_buff') and Menu.IsKeyDown(ComboKey) then
			local orchid = NPC.GetItem(My.Hero, "item_bloodthorn")
		    if not orchid then
		        orchid = NPC.GetItem(My.Hero, "item_orchid")
		    end
		    local manta = NPC.GetItem(My.Hero, "item_manta")
		    if orchid and Ability.IsReady(orchid) and Ability.IsCastable(orchid, NPC.GetMana(My.Hero)) then
		    	Ability.CastTarget(orchid, enemy)
		    end
		    if manta and Ability.IsReady(manta) and Ability.IsCastable(manta, NPC.GetMana(My.Hero)) then
		    	Ability.CastNoTarget(manta)
		    end
		end
		My.PrevCastTime = os.clock()
	end

end

function Chaos.SleepReady(sleep, lastTick)
    if not lastTick then return false end
    if (os.clock() - lastTick) >= sleep then
        return true
    end
    return false
end


return Chaos