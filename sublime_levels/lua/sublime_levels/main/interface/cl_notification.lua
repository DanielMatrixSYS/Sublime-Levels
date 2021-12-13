--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local panel = {};

AccessorFunc(panel, "Title", "Title", FORCE_STRING);
AccessorFunc(panel, "Description", "Description", FORCE_STRING);
AccessorFunc(panel, "DisplayDecline", "DisplayDecline", FORCE_BOOL);
AccessorFunc(panel, "UseTextEdit", "UseTextEdit", FORCE_BOOL);
AccessorFunc(panel, "TextEditTemp", "TextEditTemp", FORCE_STRING);
AccessorFunc(panel, "AcceptText", "AcceptText", FORCE_STRING);
AccessorFunc(panel, "DeclineText", "DeclineText", FORCE_STRING);

function panel:Init()
    self.L  = Sublime.L;
    self.C  = Sublime.Colors;
    self.CA = ColorAlpha;

    self.Children = {};
    self.Time     = SysTime();

    self.Exit = self:Add("DButton");
    self.Exit:SetText("");
    self.Exit:SetCursor("arrow");

    self.Exit.Size      = 24;
    self.Exit.IconSize  = 8;
    self.Exit.Alpha     = 125;

    self.Exit.Paint = function(panel, w, h)
        surface.SetDrawColor(255, 255, 255, panel.Alpha);
        surface.SetMaterial(Sublime.Materials["SL_X"]);
        surface.DrawTexturedRect((w / 2) - panel.IconSize / 2, (h / 2) - panel.IconSize / 2, panel.IconSize, panel.IconSize);

        panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {255, 2}, {125, 2});
    end

    self.Exit.OnCursorEntered = function()
        surface.PlaySound("sublimeui/button.mp3");
    end

    self.Exit.DoClick = function()
        if (IsValid(self)) then
            self:Remove();
        end
    end

    self.Accept = self:Add("DButton");
    self.Accept:SetText("");

    self.Accept.Alpha = 100;

    self.Accept.DoClick = function()
        self:Remove();
        self:DoAcceptClick(self);
    end

    self.Accept.Paint = function(panel, w, h)
        local color1 = self.CA(Sublime:LightenColor(self.C.Green, 25), panel.Alpha);
        local color2 = self.CA(Sublime:DarkenColor(self.C.Green, 25), panel.Alpha);
        
        Sublime:DrawRoundedGradient(panel, 16, 0, 0, w, h, color1, color2);

        Sublime:DrawTextOutlined(self.L("notification_accept"), "Sublime.20", w / 2, h / 2, self.C.White, self.C.Black, TEXT_ALIGN_CENTER, true);
        panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {150, 2}, {100, 2});
    end
end

function panel:DoAcceptClick()
    return true;
end

function panel:DoDeclineClick()
    return true;
end

function panel:GetTextEntryValue()
    if (IsValid(self.TextEdit)) then
        return self.TextEdit:GetValue();
    end

    return "";
end

function panel:PerformLayout(w, h)
    self.Exit:SetPos(w - 22, 11);
    self.Exit:SetSize(12, 12);

    if (self.DisplayDecline) then
        self.Accept:SetPos(7, h - 42);
        self.Accept:SetSize((w / 2) - 14, 35);

        self.Decline:SetPos((w / 2) + 7, h - 42);
        self.Decline:SetSize((w / 2) - 14, 35);
    else
        self.Accept:SetPos(w / 4, h - 42);
        self.Accept:SetSize(w / 2, 35);
    end

    if (IsValid(self.TextEdit)) then
        self.TextEdit:SetPos(7, h / 2);
        self.TextEdit:SetSize(w - 14, 30);

        self.TextEdit:RequestFocus();
    end
end

function panel:Think()
    if (self.DisplayDecline and not self.DDHasBeenCalled) then
        self.Decline = self:Add("DButton");
        self.Decline:SetText("");
        self.Decline:SetTextColor(self.C.White);

        self.Decline.Alpha = 100;

        self.Decline.DoClick = function()
            self:Remove();
            self:DoDeclineClick();
        end

        self.Decline.Paint = function(panel, w, h)
            local color1 = self.CA(Sublime:LightenColor(self.C.Red, 25), panel.Alpha);
            local color2 = self.CA(Sublime:DarkenColor(self.C.Red, 25), panel.Alpha);

            Sublime:DrawRoundedGradient(panel, 16, 0, 0, w, h, color1, color2);

            panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {150, 2}, {100, 2});
            Sublime:DrawTextOutlined(self.L("notification_decline"), "Sublime.20", w / 2, h / 2, self.C.White, self.C.Black, TEXT_ALIGN_CENTER, true);
        end

        self.DDHasBeenCalled = true;
    end

    if (self.UseTextEdit and not self.TEHasBeenCalled) then
        self.TextEdit = self:Add("DTextEntry");
        self.TextEdit:SetFont("Sublime.20");
        self.TextEdit:SetDrawLanguageID(false);
        
        if (self.TextEditTemp) then
            self.TextEdit:SetText(self.TextEditTemp);
        end

        self.TextEdit.Paint = function(s, w, h)
            surface.SetDrawColor(0, 0, 0, 255);
            surface.DrawOutlinedRect(0, 0, w, h);

            surface.SetDrawColor(self.C.Outline);
            surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

            s:DrawTextEntryText(self.C.White, self.C.Black, self.C.White);
        end

        self.TEHasBeenCalled = true;
    end
end

function panel:Paint(w, h)
    Derma_DrawBackgroundBlur(self, self.Time);

    surface.SetDrawColor(255, 255, 255, 255);
    surface.SetMaterial(Sublime.Materials["SL_Background"]);
    surface.DrawTexturedRect(0, 0, w, h);
    surface.DrawTexturedRect(2, 2, w - 4, 30);

    surface.SetDrawColor(0, 0, 0, 255);
    surface.DrawOutlinedRect(0, 0, w, h);

    surface.SetDrawColor(self.C.Outline);
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
    surface.DrawRect(2, 32, w - 4, 1)

    Sublime:DrawTextOutlined(self.Title, "Sublime.20", 5, 9, self.C.White, self.C.Black, TEXT_ALIGN_LEFT);
    Sublime:DrawTextOutlined(Sublime.textWrap(self.Description, "Sublime.20", w - 14), "Sublime.20", w / 2, 55, self.C.White, self.C.Black, TEXT_ALIGN_CENTER);
end
vgui.Register("Sublime.Notification", panel, "EditablePanel");