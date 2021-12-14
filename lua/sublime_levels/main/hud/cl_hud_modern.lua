--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local color = Sublime.Colors;

local localplayer;
local experience = 0;

local w, h = ScrW(), ScrH();

local barWidth, barHeight   = w / 2.5, 20;
local barPosX, barPosY      = (w / 2) - (barWidth / 2), h - (barHeight + 5);

local round         = math.Round;
local comma         = string.Comma;
local lerp          = Lerp;
local approach      = math.Approach;
local colorAlpha    = ColorAlpha;

local color_func = Color;

local darkRoyal = Sublime:DarkenColor(color.Royal, 50);

local gained    = 0;
local received  = 0;
local alpha     = 0;
local lifetime  = CurTime();

hook.Add("HUDPaint", path, function()
    localplayer = localplayer and IsValid(localplayer) and localplayer or LocalPlayer();

    if (not IsValid(localplayer)) then
        return;
    end

    local shouldDisplayHUD = Sublime.Settings.Get("hud", "display", "boolean");
    if (not shouldDisplayHUD) then
        return;
    end

    local modern_hud = Sublime.Settings.Get("hud", "hud_modern", "boolean");
    if (not modern_hud) then
        return;
    end

    local have      = localplayer:SL_GetExperience();
    local needed    = localplayer:SL_GetNeededExperience();
    local level     = localplayer:SL_GetLevel();
    experience      = lerp(0.1, experience, have);

    local percentage = experience / needed;

    local barColor  = color_func(255 - (percentage * 255), percentage * 255, 0);
    local light     = Sublime:LightenColor(barColor, 20);
    local dark      = Sublime:DarkenColor(barColor, 20);

    Sublime:DrawRoundedGradient(nil, 8, barPosX, barPosY, barWidth, barHeight, darkRoyal, color.Royal);
    draw.RoundedBox(8, barPosX + 1, barPosY + 1, barWidth - 2, barHeight - 2, color.Black);
    Sublime:DrawRoundedGradient(nil, 8, barPosX + 1, barPosY + 1, (barWidth - 2) * percentage, barHeight - 2, dark, light);

    local str = math.ceil(round(percentage * 100, 1)) .. "%";

    surface.SetFont("Sublime.18");
    local size = surface.GetTextSize(str);
    Sublime:DrawTextOutlined(str, "Sublime.18", barPosX + (barWidth / 2) - (size / 2), barPosY + 1, color.White, color.Black, true);

    have, needed = comma(have), comma(needed);
    local size = surface.GetTextSize(have .. "/" .. needed);

    Sublime:DrawTextOutlined(have .. "/" .. needed, "Sublime.18", barPosX + (barWidth / 2), barPosY - 10, color.White, color.Black, TEXT_ALIGN_CENTER, true);
    Sublime:DrawTextOutlined("+" .. comma(gained), "Sublime.18", barPosX + (barWidth / 2), barPosY - 25, colorAlpha(color.Green, alpha), colorAlpha(color.Black, alpha), TEXT_ALIGN_CENTER, true);

    gained = approach(gained, received, 3);
    if (gained > 0) then
        if (lifetime >= CurTime()) then
            if (alpha < 255) then
                alpha = approach(alpha, 255, 2);
            end
        else
            if (alpha > 0) then
                alpha = approach(alpha, 0, 0.3);
            else
                if (alpha == 0) then
                    received = 0;
                end
            end
        end
    end
end);

hook.Add("Sublime.ExperienceReceived", path, function(gained)
    received = received + gained;
    lifetime = CurTime() + 10;
end);