--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path = Sublime.GetCurrentPath();

hook.Add("OnNPCKilled", path, function(npc, attacker)
    if (IsValid(attacker) and attacker:IsPlayer()) then
        local xp = Sublime.Settings.Get("kills", "npc_on_kill_experience", "number");

        attacker:SL_AddExperience(xp, "for killing an npc.");
    end
end);

hook.Add("PlayerDeath", path, function(victim, _, attacker)
    if (IsValid(victim) and IsValid(attacker) and attacker:IsPlayer()) then

        ---
        --- We have another playerdeath hook for the TTT gamemode.
        ---

        if (Sublime.GetCurrentGamemode() == "terrortown") then
            return;
        end

        ---
        --- We have another playerdeath hook for the Murder gamemode.
        ---

        if (Sublime.GetCurrentGamemode() == "murder") then
            return;
        end

        ---
        --- Continue if not ttt or murder.
        ---
        
        if (victim == attacker) then
            return;
        end

        local experience = Sublime.Settings.Get("kills", "player_on_kill_experience", "number");

        -- Headshot bonus.
        local lastHit   = victim:LastHitGroup();
        local hModifier = Sublime.Settings.Get("kills", "headshot_modifier", "number");

        if (lastHit == HITGROUP_HEAD) then
            experience = experience * hModifier;
        end

        attacker:SL_AddExperience(experience, "for killing a player.");
    end
end);

