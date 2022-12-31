local path = Sublime.GetCurrentPath();
local experience = 0;
local localplayer;
local round = math.Round;
local comma = string.Comma;

local gained    = 0
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

    local circle_hud = Sublime.Settings.Get("hud", "hud_circle", "boolean");
    if (not circle_hud) then
        return;
    end

    local x = Sublime.Settings.Get("hud", "hud_x", "number");
    local y = Sublime.Settings.Get("hud", "hud_y", "number");

    local have      = localplayer:SL_GetExperience();
    local needed    = localplayer:SL_GetNeededExperience();
    local level     = localplayer:SL_GetLevel();
    experience      = Lerp(0.1, experience, have);

    draw.NoTexture();
    Sublime.Arc(x, y, 40, 5, 0, 362, 0, Sublime.Colors.Trans);

    local xp_perc = have / needed;
    local col = Color((1 - xp_perc) * 255, xp_perc * 255, 0);

    Sublime.Arc(x, y, 40, 5, 0, round((experience / needed) * 362), 0, col);

    Sublime:DrawTextOutlined(level .. "/" .. Sublime.Settings.Table["SERVER"]["other"]["max_level"], "Sublime.22", x, y + 55, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);
    Sublime:DrawTextOutlined(comma(round(experience)) .. "/" .. comma(needed), "Sublime.22", x, y + 75, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);

    gained = math.Approach(gained, received, 3);
    if (gained > 0) then
        if (lifetime >= CurTime()) then
            if (alpha < 255) then
                alpha = math.Approach(alpha, 255, 2);
            end
        else
            if (alpha > 0) then
                alpha = math.Approach(alpha, 0, 2);
            else
                received = 0;
            end
        end

        Sublime:DrawTextOutlined("+" .. comma(gained), "Sublime.22", x - 1, y - 1, Color(255, 255, 255, alpha), Color(0, 0, 0, alpha), TEXT_ALIGN_CENTER, true);
    end
end);

hook.Add("Sublime.ExperienceReceived", path, function(gained)
    lifetime = CurTime() + 10;
    received = received + gained;
end);