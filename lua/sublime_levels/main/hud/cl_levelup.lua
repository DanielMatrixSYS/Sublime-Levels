local path      = Sublime.GetCurrentPath();
local dNoti     = false;
local w, h      = ScrW(), ScrH();
local texts     = {}
local lifetime  = CurTime();
local fadeout   = false;
local sRemove   = false;
local ca        = ColorAlpha;
local approach  = math.Approach;
local r         = math.random;

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

        local text      = tData.text;
        local display   = tData.shouldDisplay;
        local alpha     = tData.alpha;
        local font      = tData.font;
        local padding   = tData.padding;
        local color     = tData.color;

        if (display <= CurTime()) then
            if (not fadeout) then
                texts[i].alpha = approach(texts[i].alpha, 255, 1);
            else
                texts[i].alpha = approach(texts[i].alpha, 0, 1);

                if (texts[i].alpha <= 1) then
                    sRemove = true;
                end
            end
            
            color = ca(color, alpha);

            Sublime:DrawTextOutlined(text, font, w / 2, (h / 4) + (30 * (i - 1)) + padding, color, Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER, true);
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
    local time = CurTime();

    table.insert(texts, {text = "Congratulations, " .. LocalPlayer():Nick() .. "!", shouldDisplay = time, alpha = 0, font = "Sublime.36", padding = 0, color = Color(240, 240, 240)});
    table.insert(texts, {text = "You have reached level:", shouldDisplay = time + 2, alpha = 0, font = "Sublime.36", padding = 10, color = Color(240, 240, 240)});
    table.insert(texts, {text = nLevel, shouldDisplay = time + 4, alpha = 0, font = "Sublime.LevelUp.Level", padding = 30, color = Color(r(0, 255), r(0, 255), r(0, 255))});
    
    if (Sublime.Settings.Table["SERVER"]["other"]["skills_enabled"]) then
        table.insert(texts, {text = "You have been given a Skill Point.", shouldDisplay = time + 7, alpha = 0, font = "Sublime.22", padding = 50, color = Color(240, 240, 240)});
    end

    lifetime = CurTime() + 12;
    fadeout = false;
    sRemove = false;
    dNoti = true;
end);