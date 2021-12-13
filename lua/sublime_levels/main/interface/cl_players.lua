--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local comma = string.Comma;

local panel = {};

---
--- PostInit
---
function panel:PostInit()
    local count     = player.GetCount();
    local players   = player.GetAll();

    for i = 1, count do
        local ply = players[i];

        if (IsValid(ply)) then
            self:AddPlayer(self.ScrollPanel, ply);
        end
    end

    self.PostInitCalled = true;
end

---
--- AddPlayer
---
function panel:AddPlayer(parent, ply)
    local nextPlayer    = #parent.Players + 1;
    local nick          = ply:Nick();
    local level         = ply:GetNW2Int("sl_level", 1);
    local experience    = ply:GetNW2Int("sl_experience", 0);
    local needed        = ply:SL_GetNeededExperience();

    parent.Players[nextPlayer] = parent:Add("DButton");
    parent.Players[nextPlayer].Alpha = 100;
    parent.Players[nextPlayer]:SetText("");
    parent.Players[nextPlayer]:SetPos(5, 5 + 35 * (nextPlayer - 1));
    parent.Players[nextPlayer]:SetSize(parent:GetWide() - (10 + (vBarPresent and 20 or 0)), 30);
    parent.Players[nextPlayer].PerformLayout = function(s, w, h)
        if (IsValid(s.Avatar)) then
            s.Avatar:SetPos(5, (h / 2) - s.Avatar.MaskSize / 2);
            s.Avatar:SetSize(s.Avatar.MaskSize, s.Avatar.MaskSize);
        end
    end
    
    parent.Players[nextPlayer].Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, s.Alpha));

        if (s:IsHovered()) then
            if (Sublime.Config.ConfigAccess[LocalPlayer():GetUserGroup()]) then
                Sublime:DrawPanelTip(s, "Left click on the player row to adjust the players leveling data");
            end

            s.Alpha = math.Approach(s.Alpha, 200, 4);
        else
            if (s.Alpha > 100) then
                s.Alpha = math.Approach(s.Alpha, 100, 2);
            end
        end

        Sublime:DrawTextOutlined(nick, "Sublime.18", 31, h / 2, self.C.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
        Sublime:DrawTextOutlined(level .. "/" .. Sublime.Settings.Table["SERVER"]["other"]["max_level"], "Sublime.18", (w / 2) - 9, h / 2, self.C.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
        Sublime:DrawTextOutlined(comma(experience) .. "/" .. comma(needed), "Sublime.18", w - 5, h / 2, self.C.White, Sublime.Colors.Black, TEXT_ALIGN_RIGHT, true);
    end

    parent.Players[nextPlayer].DoClick = function()
        if (not Sublime.Config.ConfigAccess[LocalPlayer():GetUserGroup()]) then
            Sublime.MakeNotification("Invalid Access", "You don't have access to this side of things, if you believe this is wrong then contact the server owner.", "Ok", false);

            return;
        end

        local parent = self:GetParent();

        -- Remove the scoreboard
        self:Remove();

        -- Display the selected players data.
        self.Profile = parent:Add("Sublime.Profile")
        self.Profile:SetPos(152, 33);
        self.Profile:SetSize(parent:GetWide() - 154, parent:GetTall() - 35);
        self.Profile:SetPlayer(ply);
    end

    parent.Players[nextPlayer].Avatar = parent.Players[nextPlayer]:Add("Sublime.AvatarCircleMask")
    parent.Players[nextPlayer].Avatar.MaskSize = 21;
	parent.Players[nextPlayer].Avatar:SetPlayer(ply);
	parent.Players[nextPlayer].Avatar:SetMaskSize(parent.Players[nextPlayer].Avatar.MaskSize / 2);
end

---
--- Init
---
function panel:Init()
    self.L = Sublime.L;
    self.C = Sublime.Colors;
    self.CA = ColorAlpha;

    self.ScrollPanel = self:Add("DScrollPanel");
    self.ScrollPanel.Players = {};

    self.ScrollPanel.PaintOver = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
    end

    local vBar = self.ScrollPanel:GetVBar();

    vBar:SetWidth(0);

    vBar.Paint = function()
        return true;
    end

    vBar.btnUp.Paint = function()
        return true;
    end

    vBar.btnDown.Paint = function()
        return true;
    end

    vBar.btnGrip.Paint = function()
        return true;
    end
end

---
--- PerformLayout
---
function panel:PerformLayout(w, h)
    self.ScrollPanel:SetPos(5, 40);
    self.ScrollPanel:SetSize(w - 10, h - 45);
end

---
--- Think
---
function panel:Think()
    if (not self.PostInitCalled and self.ScrollPanel:GetWide() > 64) then
        self:PostInit();
    end
end

---
--- Paint
---
function panel:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 0);
    surface.DrawRect(0, 0, w, h);

    draw.RoundedBox(8, 5, 5, w - 10, 30, Color(0, 0, 0, 100));

    Sublime:DrawTextOutlined("Name", "Sublime.20", 15, 20, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
    Sublime:DrawTextOutlined("Level", "Sublime.20", (w / 2) - 10, 20, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
    Sublime:DrawTextOutlined("Experience", "Sublime.20", w - 15, 20, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_RIGHT, true);
end
vgui.Register("Sublime.Players", panel, "EditablePanel");

