local panel = {};

function panel:CreateButtons()
    for i = #self.Buttons, 1, -1 do
        local data = self.Buttons[i];
        
        if (data.shouldShow ~= nil and not data.shouldShow) then
            table.remove(self.Buttons, i);
        end
    end
    
    for i = 1, #self.Buttons do
        local data = self.Buttons[i];

        self.CreatedButtons[i] = self.ButtonHolder:Add("DButton");
        self.CreatedButtons[i]:SetText("");
        self.CreatedButtons[i].Alpha = 100;
        self.CreatedButtons[i].Paint = function(panel, w, h)
            local color1 = self.CA(Sublime:LightenColor(data.color1, 50), panel.Alpha);
            local color2 = self.CA(Sublime:DarkenColor(data.color1, 25), panel.Alpha);

            Sublime:DrawRoundedGradient(panel, 8, 0, 0, w, h, color1, color2);
            Sublime:DrawTextOutlined(data.name, "Sublime.18", 26, h / 2, self.C.White, self.C.Black, TEXT_ALIGN_LEFT, true);
            
            local icon_size = 16;
            Sublime:DrawMaterialOutline(5, (h / 2) - (icon_size / 2), icon_size, icon_size, data.mat, self.C.Black, self.C.White);
            
            if (self.Selected == panel) then
                Sublime:DrawMaterialRotatedOutline(w - 10, h / 2, icon_size, icon_size, Sublime.Materials["SL_LeftArrow"], self.C.Black, self.C.White, 180);
            end

            panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {150, 2}, {100, 2});
        end

        self.CreatedButtons[i].DoClick = function(s)
            if (IsValid(self.CreatedPanel)) then
                self.CreatedPanel:Remove();
            end

            self.Selected     = s;
            self.CreatedPanel = self:Add(data.ui);
            self.CreatedPanel:SetPos(152, 33);
            self.CreatedPanel:SetSize(self:GetWide() - 154, self:GetTall() - 35);
            self.CreatedPanel.name = data.name;

            if (data.func) then
                data.func(self.CreatedPanel);
            end

            return true;
        end

        self.CreatedButtons[i].OnCursorEntered = function()
            surface.PlaySound("sublime_levels/button.mp3");
        end

        -- We should display the XP Settings panel at ui startup.
        if (data.name == self.L("home_home")) then
            self.Selected       = self.CreatedButtons[i];
            self.CreatedPanel   = self:Add(data.ui);
        end
    end
end

---
--- Init
---
function panel:Init()
    self.Time           = SysTime();
    self.CreatedButtons = {};
    self.L              = Sublime.L;

    self.CA = ColorAlpha;
    self.C  = Sublime.Colors;

    self.Buttons = {
        {
            name = self.L("home_home"),
            ui = "Sublime.Home",
            color1 = Sublime.Colors.White,
            mat = Sublime.Materials["SL_Home"],
        },

        {
            name = self.L("home_players"),
            ui = "Sublime.Players",
            color1 = Sublime.Colors.Orange,
            mat = Sublime.Materials["SL_User"],
        },

        {
            name = self.L("home_leaderboards"),
            ui = "Sublime.Leaderboards",
            color1 = Sublime.Colors.Royal,
            mat = Sublime.Materials["SL_Leaderboards"],
        },

        {
            name = self.L("home_skills"),
            ui = "Sublime.Skills",
            color1 = Sublime.Colors.Yellow,
            mat = Sublime.Materials["SL_Upgrade"],
            shouldShow = Sublime.Settings.Table["SERVER"]["other"].skills_enabled
        },

        {
            name = self.L("home_options"),
            ui = "Sublime.Options",
            color1 = Sublime.Colors.Red,
            mat = Sublime.Materials["SL_AdminSettings"],
        },
    }

    -- The panel that holds the buttons
    self.ButtonHolder = self:Add("DPanel");
    self.ButtonHolder.PerformLayout = function(s, w, h)
        for i = 1, #self.CreatedButtons do
            local button = self.CreatedButtons[i];

            if (IsValid(button)) then
                button:SetPos(5, 5 + (35 * (i - 1)));
                button:SetSize(w - 11, 30)
            end
        end
    end

    self.ButtonHolder.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 100);
        surface.DrawRect(0, 0, w, h);

        surface.SetDrawColor(Sublime.Colors.Outline);
        surface.DrawRect(w - 1, 0, 1, h);
    end

    -- Exit
    local greyAlpha = 200;
    self.Exit = self:Add("DButton");
    self.Exit:SetText("");
    self.Exit:SetCursor("arrow");
    self.Exit.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 0);
        surface.DrawRect(0, 0, w, h);

        if (s:IsHovered()) then
            greyAlpha = math.Approach(greyAlpha, 150, 2)
        else
            greyAlpha = math.Approach(greyAlpha, 200, 2);
        end

        surface.SetDrawColor(ColorAlpha(Sublime.Colors.Grey, greyAlpha));
        surface.SetMaterial(Sublime.Materials["SL_X"]);
        surface.DrawTexturedRect((w / 2) - ((w - 10) / 2), (h / 2) - ((h - 10) / 2), 12, 12);
    end

    self.Exit.OnCursorEntered = function()
        surface.PlaySound("sublime_levels/button.mp3");
    end
    
    self.Exit.DoClick = function()
        if (IsValid(self)) then
            self:Remove();
        end
    end
end

---
--- Think
---
function panel:Think()
    if (not self.PostInitCalled) then
        self:PostInit();

        self.PostInitCalled = true;
    end
end

---
--- PostInit
---
function panel:PostInit()
    self:CreateButtons();
end

---
--- PerformLayout
---
function panel:PerformLayout(w, h)
    self.ButtonHolder:SetPos(2, 33);
    self.ButtonHolder:SetSize(150, h - 35);

    self.Exit:SetPos(w - 29, 6);
    self.Exit:SetSize(24, 24);

    if (not self.HasCreatedHomePanel and IsValid(self.CreatedPanel)) then
        self.CreatedPanel:SetPos(152, 33);
        self.CreatedPanel:SetSize(w - 154, h - 35);

        self.HasCreatedHomePanel = true;
    end
end

---
--- Paint
---
function panel:Paint(w, h)
    -- Background Blur
    if (Sublime.Settings.Get("interface", "blur", "boolean")) then
        Derma_DrawBackgroundBlur(self, self.Time);
    end

    -- Main Background Image
    surface.SetDrawColor(255, 255, 255);
    surface.SetMaterial(Sublime.Materials["SL_Background"]);
    surface.DrawTexturedRect(2, 2, w - 4, h - 4);
    surface.DrawTexturedRect(2, 2, w - 4, 30);

    -- Black Outline
    surface.SetDrawColor(0, 0, 0);
    surface.DrawOutlinedRect(0, 0, w, h)

    -- Outline
    surface.SetDrawColor(Sublime.Colors.Outline);
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
    surface.DrawRect(2, 32, w - 4, 1)

    Sublime:DrawTextOutlined("Sublime Levels", "Sublime.20", 8, 17, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
end
vgui.Register("Sublime.Interface", panel, "EditablePanel");