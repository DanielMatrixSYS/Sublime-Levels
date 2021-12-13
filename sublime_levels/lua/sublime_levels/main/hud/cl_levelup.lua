--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path      = Sublime.GetCurrentPath();
local dNoti     = false;
local w, h      = ScrW(), ScrH();
local texts     = {}
local lifetime  = CurTime();
local fadeout   = false;
local sRemove   = false;

hook.Add("HUDPaint", path, function()
    local shouldDisplayHUD = Sublime.Settings.Get("hud", "display", "boolean");
    
    if (not dNoti or not shouldDisplayHUD) then
        return;
    end

    for i = 1, #texts do
        local tData = texts[i];

        if (not tData) then
            continue;
        end

        local text = tData.text;
        local display = tData.shouldDisplay;
        local alpha = tData.alpha;
        local font = tData.font;
        local padding = tData.padding;

        if (display <= CurTime()) then
            if (not fadeout) then
                texts[i].alpha = math.Approach(texts[i].alpha, 255, 1);
            else
                texts[i].alpha = math.Approach(texts[i].alpha, 0, 1);

                if (texts[i].alpha <= 0) then
                    sRemove = true;
                end
            end

            Sublime:DrawTextOutlined(text, font, w / 2, (h / 4) + (30 * (i - 1)) + padding, Color(255, 255, 255, alpha), Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
        end
    end

    if (lifetime <= CurTime()) then
        fadeout = true;

        if (sRemove) then
            dNoti = false;
            table.Empty(texts);
        end
    end
end);

hook.Add("Sublime.LevelUpNotification", path, function(nLevel)
    table.insert(texts, {text = "Congratulations, " .. LocalPlayer():Nick() .. ".", shouldDisplay = CurTime(), alpha = 0, font = "Sublime.36.P", padding = 0});
    table.insert(texts, {text = "You have reached level: " .. nLevel, shouldDisplay = CurTime() + 2, alpha = 0, font = "Sublime.36.P", padding = 5});
    table.insert(texts, {text = "You have been given a Skill Point.", shouldDisplay = CurTime() + 4, alpha = 0, font = "Sublime.30.P", padding = 50});
    table.insert(texts, {text = "Your leaderboards position has changed.", shouldDisplay = CurTime() + 5, alpha = 0, font = "Sublime.30.P", padding = 50});

    lifetime = CurTime() + 10;
    fadeout = false;
    sRemove = false;
    dNoti = true;
end);