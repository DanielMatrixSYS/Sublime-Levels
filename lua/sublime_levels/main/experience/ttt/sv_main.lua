local path = Sublime.GetCurrentPath();
local playerRoles = {};

hook.Add("PlayerDeath", path, function(victim, _, attacker)
    if (IsValid(victim) and IsValid(attacker) and attacker:IsPlayer()) then
        if (Sublime.GetCurrentGamemode() == "terrortown") then
            if (victim == attacker) then
                return;
            end
            
            --
            -- Refuse experience to the killer if he killed a ghost
            -- This is for Tommy's SpecDM.
            -- https://github.com/Tommy228/TTT_Spectator_Deathmatch
            --

            if (SpecDM and not Sublime.Config.SpecExperience and victim:IsGhost()) then
                return;
            end

            ---
            --- Teamkilling grants 0 experience for the attacker, however,
            --- if the victims team wins then the victim will still get experience(if enabled.).
            ---
            
            playerRoles[victim] = victim:GetRole();

            if (victim:IsTraitor() and attacker:IsTraitor()) then
                return;
            end

            if (not victim:IsTraitor() and not attacker:IsTraitor()) then
                return;
            end

            local experience;
            local source;

            local xp_traitor_kill   = Sublime.Settings.Get("ttt", "killing_traitors", "number");
            local xp_innocent_kill  = Sublime.Settings.Get("ttt", "killing_innocent", "number");
            local xp_detective_kill = Sublime.Settings.Get("ttt", "killing_detective", "number");

            if (victim:IsTraitor()) then
                experience = xp_traitor_kill;
                source = "for killing a Traitor"
            elseif(victim:IsDetective()) then
                experience = xp_detective_kill;
                source = "for killing a detective";
            else
                experience = xp_innocent_kill;
                source = "for killing an innocent";
            end

            -- Headshot bonus.
            local lastHit   = victim:LastHitGroup();
            local hModifier = Sublime.Settings.Get("kills", "headshot_modifier", "number");

            if (lastHit == HITGROUP_HEAD) then
                experience = experience * hModifier;
            end

            attacker:SL_AddExperience(experience, source);
        end
    end
end);

//Hook edited on 28.11.2021. Daniel.
hook.Add("TTTEndRound", path, function(result)
    local pCount    = player.GetCount();
    local players   = player.GetAll();

    local traitor_win   = Sublime.Settings.Get("ttt", "traitor_winners", "number");
    local innocent_win  = Sublime.Settings.Get("ttt", "innocent_winners", "number");
    local draw_win      = Sublime.Settings.Get("ttt", "draw", "number");

    //28.11.2021. Daniel.
    local b_ShouldInnocentGetExperienceIfDead   = Sublime.Settings.Get("ttt", "should_innocent_get_xp_when_dead", "boolean");
    local b_ShouldTraitorGetExperienceIfDead    = Sublime.Settings.Get("ttt", "should_traitor_get_xp_when_dead", "boolean");
    local b_ShouldSpectatorGetExperienceWhenRoundEnd = Sublime.Settings.Get("ttt", "should_spectators_get_xp_when_roundend", "boolean");

    for i = 1, pCount do
        local ply = players[i];

        if (IsValid(ply)) then
            if (result == WIN_TRAITOR) then
                if (ply:Alive()) then
                    if (ply:IsTraitor() and ply:Team() ~= TEAM_SPECTATOR and not b_ShouldSpectatorGetExperienceWhenRoundEnd) then
                        ply:SL_AddExperience(traitor_win, "for winning the round as a traitor.");
                    end
                else
                    if (playerRoles[ply] and playerRoles[ply] == ROLE_TRAITOR) then
                        if (b_ShouldTraitorGetExperienceIfDead) then
                            ply:SL_AddExperience(traitor_win, "for winning the round as a traitor.");
                        end
                    end
                end
            elseif (result == WIN_INNOCENT) then
                if (ply:Alive()) then
                    if (not ply:IsTraitor() and ply:Team() ~= TEAM_SPECTATOR and not b_ShouldSpectatorGetExperienceWhenRoundEnd) then
                        ply:SL_AddExperience(innocent_win, "for winning the round as an innocent.");
                    end
                else
                    if (playerRoles[ply] and playerRoles[ply] == ROLE_INNOCENT or playerRoles[ply] and playerRoles[ply] == ROLE_DETECTIVE) then
                        if (b_ShouldInnocentGetExperienceIfDead) then
                            ply:SL_AddExperience(innocent_win, "for winning the round as an innocent.");
                        end
                    end
                end
            else
                if (ply:Alive()) then
                    if (ply:Team() ~= TEAM_SPECTATOR and not b_ShouldSpectatorGetExperienceWhenRoundEnd) then
                        ply:SL_AddExperience(draw_win, "as the round came to a draw.");
                    end
                else
                    if (playerRoles[ply] and playerRoles[ply] == ROLE_INNOCENT or playerRoles[ply] and playerRoles[ply] == ROLE_DETECTIVE) then
                        if (b_ShouldInnocentGetExperienceIfDead) then
                            ply:SL_AddExperience(draw_win, "as the round came to a draw.");
                        end
                    else
                        if (playerRoles[ply] and playerRoles[ply] == ROLE_TRAITOR) then
                            if (b_ShouldTraitorGetExperienceIfDead) then
                                ply:SL_AddExperience(draw_win, "as the round came to a draw.");
                            end
                        end
                    end
                end
            end
        end
    end

    playerRoles = {};
end);

