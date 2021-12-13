--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path = Sublime.GetCurrentPath();
local experience = 0;
local localplayer;

---
--- For when we gain experience
---
local width     = ScrW();
local size      = 25;

hook.Add("HUDPaint", path, function()
    localplayer = localplayer and IsValid(localplayer) and localplayer or LocalPlayer();

    if (not IsValid(localplayer)) then
        return;
    end

    local shouldDisplayHUD = Sublime.Settings.Get("hud", "display", "boolean");
    if (not shouldDisplayHUD) then
        return;
    end

    local bar_hud = Sublime.Settings.Get("hud", "hud_bar", "boolean");
    if (not bar_hud) then
        return;
    end

    local y = Sublime.Settings.Get("hud", "hud_y", "number");

    local have      = localplayer:SL_GetExperience();
    local needed    = localplayer:SL_GetNeededExperience();
    local level     = localplayer:SL_GetLevel();
    experience      = Lerp(0.1, experience, have);

    surface.SetDrawColor(0, 0, 0, 150);
    surface.DrawRect(0, y - size, width, size);

    surface.SetDrawColor(Sublime.Colors.Outline);
    surface.DrawRect(0, y - size, width, 1);
    surface.DrawRect(0, y, width, 1);
    
    local perc = experience / needed;
    surface.DrawRect(0, y - 24, width * perc, size - 1);

    Sublime:DrawTextOutlined(math.floor(perc * 100) .. "%", "Sublime.22.P", width / 2, y - 13, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);
    Sublime:DrawTextOutlined(level - 1, "Sublime.22.P", 5, y - 13, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
    Sublime:DrawTextOutlined(level + 1, "Sublime.22.P", width - 5, y - 13, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_RIGHT, true);
end);