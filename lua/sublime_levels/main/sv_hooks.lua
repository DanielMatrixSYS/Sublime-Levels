--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

util.AddNetworkString("Sublime.BroadcastLevelUp");
util.AddNetworkString("Sublime.Interface");
util.AddNetworkString("Sublime.RequestInterface");
util.AddNetworkString("Sublime.PlayerReceivedExperience");

local SQL   = Sublime.GetSQL();
local path  = Sublime.GetCurrentPath();

hook.Add("PlayerDisconnected", path, function(ply)
    if (not ply:IsBot()) then
        ply:SL_Save();
    end
end);

local function openSublimeMenu(ply)
    local total_xp      = sql.QueryValue(SQL:FormatSQL("SELECT TotalExperience FROM Sublime_Levels WHERE SteamID = '%s'", ply:SteamID64()));
    local global_data   = sql.Query("SELECT ExperienceGained, LevelsGained FROM Sublime_Data");
    local ranks         = sql.Query("SELECT SteamID FROM Sublime_Levels ORDER BY TotalExperience DESC");
    local to            = tonumber;
    local my_position   = 0;
    local my_steamid    = ply:SteamID64(); 

    for i = 1, #ranks do
        local data = ranks[i];

        if (data) then
            local steamid = data["SteamID"];

            if (steamid == my_steamid) then
                my_position = i;

                break;
            end
        end
    end

    net.Start("Sublime.Interface");
        net.WriteUInt(to(total_xp), 32);
        net.WriteUInt(to(global_data[1]["ExperienceGained"]), 32);
        net.WriteUInt(to(global_data[1]["LevelsGained"]), 32);
        net.WriteUInt(my_position, 32);
    net.Send(ply);
end

hook.Add("PlayerSay", path, function(ply, text)
    local text = text:lower();
    local cmd = Sublime.Settings.Get("other", "chat_command", "string");

    if (text == "/" .. cmd or text == "!" .. cmd) then
        openSublimeMenu(ply);

        return ""
    end
end);

hook.Add("SL.PlayerLeveledUp", path, function(ply, new, points)
    ply:SL_AddSkillPoint(points);

    local broadcast = Sublime.Settings.Get("other", "should_broadcast_levelup", "boolean");

    if (broadcast) then
        net.Start("Sublime.BroadcastLevelUp");
            net.WriteEntity(ply);
            net.WriteUInt(new, 32);
        net.Broadcast();
    end
end);

hook.Add("SL.PlayerReceivedExperience", path, function(ply, amount)
    net.Start("Sublime.PlayerReceivedExperience");
        net.WriteUInt(amount, 32);
    net.Send(ply);
end);

hook.Add("playerCanChangeTeam", path, function(ply, team, force)
    local job = RPExtraTeams[team];

    if (job and job.level and job.level >= 1) then
        if (ply:SL_GetLevel() < job.level) then
            DarkRP.notify(ply, 1, 5, "You need to be level " .. job.level .. " to become this job.");

            return false, false;
        end
    end
end);

---
--- checkLevel
---
--- Check level function for DarkRP items.
---
local function checkLevel(ply, ent)
    local ent_level = ent.level;

    if (ent_level and ent_level > 0) then
        local player_level = ply:SL_GetLevel();

        if (player_level < ent_level) then
            DarkRP.notify(ply, 1, 2, "You need to be level " .. ent_level .. " in order to buy this.");

            return false, true;
        end
    end
end

hook.Add("canBuyPistol",        path, checkLevel);
hook.Add("canBuyAmmo",          path, checkLevel);
hook.Add("canBuyShipment",      path, checkLevel);
hook.Add("canBuyVehicle",       path, checkLevel);
hook.Add("canBuyCustomEntity",  path, checkLevel);

local nextXP = CurTime() + 600;
hook.Add("Tick", path, function()
    if (nextXP <= CurTime()) then
        local players   = player.GetAll();
        local pCount    = player.GetCount();
        
        for i = 1, pCount do
            local ply = players[i];

            if (IsValid(ply)) then
                ply:SL_AddExperience(Sublime.Settings.Get("other", "xp_for_playing", "number"), "for playing on the server.");
            end
        end

        nextXP = CurTime() + Sublime.Settings.Get("other", "xp_for_playing_when", "number");
    end
end);

net.Receive("Sublime.RequestInterface", function(_, ply)
    openSublimeMenu(ply);
end);