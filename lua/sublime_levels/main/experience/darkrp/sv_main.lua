--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path = Sublime.GetCurrentPath();

hook.Add("lotteryEnded", path, function(_, chosen)
    if (not IsValid(chosen)) then
        return;
    end

    local experience = Sublime.Settings.Get("darkrp", "lottery_winner", "number")
    chosen:SL_AddExperience(experience, "for winning the lottery!");
end);

hook.Add("onHitCompleted", path, function(hitman)
    if (not IsValid(hitman)) then
        return;
    end

    local experience = Sublime.Settings.Get("darkrp", "hitman_completed", "number")
    hitman:SL_AddExperience(experience, "for completing a hit.");
end);

hook.Add("playerArrested", path, function(_, _, actor)
    if (not IsValid(actor)) then
        return;
    end

    local experience = Sublime.Settings.Get("darkrp", "player_arrested", "number")
    actor:SL_AddExperience(experience, "for arresting an individual.");
end);

hook.Add("onPaidTax", path, function(ply)
    if (not IsValid(ply)) then
        return;
    end

    local experience = Sublime.Settings.Get("darkrp", "player_taxed", "number");
    ply:SL_AddExperience(experience, "for paying tax, like a good person.");
end);