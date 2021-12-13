--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local panel     = {};
local comma     = string.Comma;
local round     = math.Round;

-- Colors
local mainOffsetColor   = Color(34, 44, 44);
local otherOffsetColor  = Color(45, 105, 99);

---
--- CreateStats
---
--- This is used on the homepage to display stats, both global stats and personal stats.
---
function panel:CreateStats()
    local level     = self.Player:SL_GetLevel();
    local xp        = self.Player:SL_GetExperience();
    local needed    = self.Player:SL_GetNeededExperience(); 
    local points    = self.Player:SL_GetAbilityPoints();
    local max       = Sublime.Settings.Table["SERVER"]["other"]["max_level"];
    local L         = Sublime.L;

    -- Level
        self:AddStats(self.PlayerStats, L("home_level"), level .. "/" .. max, true, level, max, true);
        self:AddStats(self.GlobalStats, L("home_total"), comma(Sublime.Cached_Data["Global_Levels"]), false);
    --

    -- Experience
        self:AddStats(self.PlayerStats, L("home_experience"), comma(xp) .. "/" .. comma(needed), true, xp, needed, true);
        self:AddStats(self.PlayerStats, L("home_total_experience"), comma(Sublime.Cached_Data["Personal_Experience"]), false, xp, needed, false);
        self:AddStats(self.GlobalStats, L("home_total_experience"), comma(Sublime.Cached_Data["Global_Experience"]), false);
    --

    -- Ability Points
        if (Sublime.Settings.Table["SERVER"]["other"].skills_enabled) then
            self:AddStats(self.PlayerStats, L("home_available_points"), points, false);
        end
    --

    -- Leaderboards Rank
        self:AddStats(self.PlayerStats, L("home_leaderboards_rank"), comma(Sublime.Cached_Data["Personal_Rank"]), false);
    --
end

---
--- AddStats
---
function panel:AddStats(parent, title, description, ...)
    if (not IsValid(parent)) then
        return false;
    end

    local args      = {...};
    local nextStat  = #parent.Stats + 1;

    parent.Stats[nextStat] = parent:Add("DPanel");
    parent.Stats[nextStat].Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, 50));

        local shouldDrawProgress = args[1];

        if (shouldDrawProgress) then
            local perc = args[2] / args[3];
            local width = perc * w;
            local col   = Color((1 - perc) * 255, perc * 255, 0);

            draw.RoundedBox(8, 0, 0, width, h, self.CA(col, 50));
        end

        Sublime:DrawTextOutlined(title, "Sublime.20.P", 5, h / 2, Sublime:LightenColor(self.C.Grey, 50), Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
        Sublime:DrawTextOutlined(description, "Sublime.20.P", w - 5, h / 2, Sublime:LightenColor(self.C.Grey, 50), Sublime.Colors.Black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER);
    end
end

---
--- Init
---
function panel:Init()
    self.Player     = LocalPlayer();
    self.Experience = 0;

    self.C      = Sublime.Colors;
    self.CA     = ColorAlpha;

    self.PlayerStats = self:Add("DPanel");
    self.PlayerStats.Stats = {};
    self.PlayerStats.PerformLayout = function(s, w, h)
        for i = 1, #s.Stats do
            local panel = s.Stats[i];

            if (IsValid(panel)) then
                panel:SetPos(5, 44 + 30 * (i - 1));
                panel:SetSize(w - 10, 25);
            end
        end

        s.Avatar:SetPos(5, 4);
        s.Avatar:SetSize(30, 30);
    end

    self.PlayerStats.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));

        Sublime:DrawTextOutlined(Sublime.L("home_personal_stats"), "Sublime.32.P", w / 2, 16, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
        surface.SetDrawColor(self.C.Outline);
        surface.DrawRect(0, 38, w, 1);
    end

    self.PlayerStats.Avatar = self.PlayerStats:Add("Sublime.AvatarCircleMask");
    local avatar = self.PlayerStats.Avatar;

    avatar:SetPlayer(self.Player);

    self.GlobalStats = self:Add("DPanel");
    self.GlobalStats.Stats = {};
    self.GlobalStats.PerformLayout = function(s, w, h)
        for i = 1, #s.Stats do
            local panel = s.Stats[i];

            if (IsValid(panel)) then
                panel:SetPos(5, 44 + 30 * (i - 1));
                panel:SetSize(w - 10, 25);
            end
        end
    end

    self.GlobalStats.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
        
        surface.SetDrawColor(self.C.Outline);
        surface.DrawRect(0, 38, w, 1);

        surface.SetDrawColor(255, 255, 255);
        surface.SetMaterial(Sublime.Materials["SL_World"]);
        surface.DrawTexturedRect(5, 4, 30, 30);

        Sublime:DrawTextOutlined(Sublime.L("home_global_stats"), "Sublime.32.P", w / 2, 16, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
    end

    self:CreateStats();
end

---
--- PerformLayout
---
function panel:PerformLayout(w, h)
    self.PlayerStats:SetPos(5, 5);
    self.PlayerStats:SetSize((w / 2) - 10, h - 10);

    self.GlobalStats:SetPos(w / 2, 5);
    self.GlobalStats:SetSize((w / 2) - 5, h - 10);
end

---
--- Paint
---
function panel:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 0);
    surface.DrawRect(0, 0, w, h);
end
vgui.Register("Sublime.Home", panel, "EditablePanel");

