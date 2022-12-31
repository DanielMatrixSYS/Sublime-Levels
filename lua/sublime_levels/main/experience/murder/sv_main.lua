local path = Sublime.GetCurrentPath();

hook.Add("OnEndRoundResult", path, function(reason)
    -- reason 2 = bystanders wins.
    -- reason 1 = murderer wins.

    local by_xp = Sublime.Settings.Get("murder", "bystander_winners", "number");
    local my_xp = Sublime.Settings.Get("murder", "murderer_winners", "number");

    if (reason == 1) then
        local players   = player.GetAll();
        local count     = player.GetCount();

        for i = 1, count do
            local ply = players[i];

            if (IsValid(ply) and ply:GetMurderer()) then
                ply:SL_AddExperience(my_xp, "for winning the round as a murderer.");
            end
        end
    end

    if (reason == 2) then
        local players   = team.GetPlayers(2);
        local survivors = {}

        for _, v in ipairs(players) do
            if (v:Alive() and not v:GetMurderer()) then
                v:SL_AddExperience(by_xp, "for winning the round as a bystander.");
            end
        end
    end
end);

hook.Add("PlayerDeath", path, function(victim, _, attacker)
    if (IsValid(victim) and IsValid(attacker) and attacker:IsPlayer()) then
        if (GAMEMODE and GAMEMODE.ThisClass and GAMEMODE.ThisClass:find("murder")) then
            if (victim == attacker) then
                return;
            end

            ---
            --- Teamkilling grants 0 experience.
            ---
            
            if (not victim:GetMurderer() and not attacker:GetMurderer()) then
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
    end
end);