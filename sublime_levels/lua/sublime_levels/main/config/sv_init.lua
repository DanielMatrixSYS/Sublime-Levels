--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

util.AddNetworkString("Sublime.ResetServerSettings");
util.AddNetworkString("Sublime.SyncServerWithClients");
util.AddNetworkString("Sublime.SaveServerSideSettings");
util.AddNetworkString("Sublime.RefreshSettings");

local path = Sublime.GetCurrentPath();

net.Receive("Sublime.ResetServerSettings", function(_, ply)
    if (not Sublime.Config.ConfigAccess[ply:GetUserGroup()]) then
        return;
    end

    Sublime.Settings.Reset();
    Sublime.Print(ply:Nick() .. " has reset the server side settings to its default values.");
end);

net.Receive("Sublime.SaveServerSideSettings", function(_, ply)
    if (not Sublime.Config.ConfigAccess[ply:GetUserGroup()]) then
        return;
    end

    Sublime.Settings.Table["SERVER"] = net.ReadTable();

    Sublime.Settings.Save();
    Sublime.Settings.Sync();

    Sublime.Print(ply:Nick() .. " has saved the server side settings with his editted values.");
end);

net.Receive("Sublime.RefreshSettings", function(_, ply)
    if (not Sublime.Config.ConfigAccess[ply:GetUserGroup()]) then
        return;
    end

    Sublime.Settings.Sync();
end);

hook.Add("PlayerInitialSpawn", path, function(ply)
    timer.Simple(2, function()
        if (IsValid(ply)) then
            Sublime.Settings.Sync(ply);
        end
    end);
end);