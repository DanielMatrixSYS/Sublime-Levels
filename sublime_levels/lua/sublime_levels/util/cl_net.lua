--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local NET_TYPE_INTEGER  = 0x1;
local NET_TYPE_STRING   = 0x2;
local NET_TYPE_BOOLEAN  = 0x3;

net.Receive("Sublime.NetworkData", function()
    local net_type = net.ReadUInt(4);
    local identifier = net.ReadString();
    local value;

    if (net_type == NET_TYPE_INTEGER) then
        value = net.ReadUInt(32);
    elseif(net_type == NET_TYPE_STRING) then
        value = net.ReadString();
    else
        value = net.ReadBool();
    end

    LocalPlayer()[identifier] = value;
end);

---
--- Cache the data we receive from the server.
--- The data stored is updated when the player openes up the menu again.
---
--- This is necessary so we don't send a net message back and forth from the client & server when
--- the person is browsing through the categories.
---
Sublime.Cached_Data = {};

net.Receive("Sublime.Interface", function()
    Sublime.Cached_Data["Personal_Experience"]  = net.ReadUInt(32);
    Sublime.Cached_Data["Global_Experience"]    = net.ReadUInt(32);
    Sublime.Cached_Data["Global_Levels"]        = net.ReadUInt(32);
    Sublime.Cached_Data["Personal_Rank"]        = net.ReadUInt(32);

    local ui = vgui.Create("Sublime.Interface");
    ui:SetSize(ScrW() / 1.5, 600);
    ui:Center();
    ui:MakePopup();
end);

net.Receive("Sublime.SendLeaderboardsData", function()
    local myData    = net.ReadTable();
    local amount    = net.ReadUInt(32);
    local maxPages  = net.ReadUInt(32);
    local data      = {}
    
    for i = 1, amount do
        local position      = net.ReadUInt(32);
        local steamid       = net.ReadString();
        local level         = net.ReadUInt(8);
        local experience    = net.ReadUInt(32);
        local total_xp      = net.ReadUInt(32);
        local needed_xp     = net.ReadUInt(32);
        local name          = net.ReadString();

        table.insert(data, {
            position    = position,
            steamid     = steamid, 
            level       = level,
            experience  = experience,
            total_xp    = total_xp,
            needed_xp   = needed_xp,
            name        = name
        });
    end

    hook.Run("Sublime.LeaderboardsDataRefreshed", data, myData, maxPages);
end);

local red   = Sublime.Colors.Red;
local black = Sublime.Colors.Black;
local white = Sublime.Colors.White;
local royal = Sublime.Colors.Royal;

net.Receive("Sublime.BroadcastLevelUp", function()
    local ent   = net.ReadEntity();
    local level = net.ReadUInt(32);
    local ply   = LocalPlayer();

    if (not IsValid(ent) or not IsValid(ply)) then
        return;
    end

    local nick = ent:Nick() or "Disconnected";

    ---
    --- Do the level notification for the player himself before we broadcast to everyone.
    ---

    if (ent == ply) then
        local levelSound = Sublime.Settings.Table["SERVER"]["other"]["sound_on_level"];

        if (levelSound and levelSound ~= "") then
            surface.PlaySound(levelSound);
        end

        hook.Run("Sublime.LevelUpNotification", level);
    end

    local prefix = Sublime.Settings.Table["SERVER"]["other"]["chat_prefix"];

    chat.AddText(red, prefix, white, ": ", royal, nick, white, " has advanced to level ", red, tostring(level), white, "!");
end);

net.Receive("Sublime.ExperienceNotification", function()
    if (not Sublime.Settings.Get("other", "experience_notifications", "boolean")) then
        return;
    end

    local source = net.ReadString();
    local amount = net.ReadUInt(32);

    local prefix = Sublime.Settings.Table["SERVER"]["other"]["chat_prefix"];

    chat.AddText(red, prefix, white, ": ", royal, "You", white, " got ", red, string.Comma(amount), white, " experience " .. source);
end);

net.Receive("Sublime.UpgradeSkillNotify", function()
    local skill     = net.ReadString();
    local cAmount   = net.ReadUInt(16);
    local pCount    = net.ReadUInt(16);

    local prefix = Sublime.Settings.Table["SERVER"]["other"]["chat_prefix"];

    chat.AddText(red, prefix, white, ": ", royal, "You", white, " upgraded ", red, skill, white, " to ", red, tostring(cAmount), white, "/", red, tostring(pCount));
end);   

net.Receive("Sublime.PlayerReceivedExperience", function()
    local received = net.ReadUInt(32);

    local XPSound = Sublime.Settings.Table["SERVER"]["other"]["sound_on_xp"];

    if (XPSound and XPSound ~= "") then
        surface.PlaySound(XPSound);
    end

    hook.Run("Sublime.ExperienceReceived", received);
end);