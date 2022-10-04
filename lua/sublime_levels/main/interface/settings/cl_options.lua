local panel = {};

function panel:CreateButtons()
    for i = 1, #self.Buttons do
        local data = self.Buttons[i];

        self.CreatedButtons[i] = self.OptionsHolder:Add("DButton");
        self.CreatedButtons[i]:SetText("");
        self.CreatedButtons[i].Alpha = 100;
        self.CreatedButtons[i].Paint = function(panel, w, h)
            local color1 = self.CA(Sublime:LightenColor(data.color, 50), panel.Alpha);
            local color2 = self.CA(Sublime:DarkenColor(data.color, 25), panel.Alpha);

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
            if (data.clickoverride) then
                data.clickoverride(s);

                return true;
            end

            if (IsValid(self.CreatedPanel)) then
                self.CreatedPanel:Remove();
            end

            self.Selected     = s;
            self.CreatedPanel = self:Add(data.ui);
            self.CreatedPanel:SetPos(150, 0);
            self.CreatedPanel:SetSize(self:GetWide() - 150, self:GetTall());

            if (data.func) then
                data.func(self.CreatedPanel);
            end

            return true;
        end

        self.CreatedButtons[i].OnCursorEntered = function()
            surface.PlaySound("sublime_levels/button.mp3");
        end

        -- We should display the XP Settings panel at ui startup.
        if (data.name == self.L("client_settings")) then
            self.Selected       = self.CreatedButtons[i];
            self.CreatedPanel   = self:Add(data.ui);
            self.CreatedPanel:SetPos(150, 0);
            self.CreatedPanel:SetSize(self:GetWide() - 150, self:GetTall());
        end
    end
end

function panel:Init()
    self.CreatedButtons = {};
    self.L              = Sublime.L;
    self.WarningMessage = "";
    self.WarningColor   = Sublime.Colors.White;
    self.C              = Sublime.Colors;
    self.CA             = ColorAlpha;
    self.Player         = LocalPlayer(); 

    self.Buttons = {
        {
            name = self.L("client_settings"),
            ui = "Sublime.OptionsClient",
            color = Sublime.Colors.BlueIsh,
            mat = Sublime.Materials["SL_Settings"],
            access = true,
        },

        {
            name = self.L("server_settings"),
            ui = "Sublime.OptionsServer",
            color = Sublime.Colors.YellowIsh,
            mat = Sublime.Materials["SL_ServerSettings"],
            access = Sublime.Config.ConfigAccess[self.Player:GetUserGroup()],
        },

        {
            name = self.L("skill_settings"),
            ui = "Sublime.OptionsSkills",
            color = Sublime.Colors.Green,
            mat = Sublime.Materials["SL_Upgrade"],
            access = Sublime.Config.ConfigAccess[self.Player:GetUserGroup()],
            enabled = false,
        },

        {
            name = self.L("reset_database"),
            ui = "Sublime.OptionsServer",
            color = Sublime.Colors.Black,
            mat = Sublime.Materials["SL_ServerSettings"],
            access = Sublime.Config.ConfigAccess[self.Player:GetUserGroup()],
            clickoverride = function()
                if (not LocalPlayer():IsSuperAdmin()) then
                    Sublime.MakeNotification("Invalid Usergroup", "You need to be a Superadmin in order to use this.");

                    return;
                end

                local notification = Sublime.MakeNotification(self.L("skills_are_you_sure"), "Are you sure you want to reset the database?\nThis requires a map restart.", true);
                notification.DoAcceptClick = function()
                    net.Start("Sublime.ResetDatabase");
                    net.SendToServer();
                end
            end
        },
    }

    for i = #self.Buttons, 1, -1 do
        local data = self.Buttons[i];

        if (not data.access or data.enabled == false) then
            table.remove(self.Buttons, i);
        end
    end

    self.OptionsHolder = self:Add("DPanel");
    self.OptionsHolder.PerformLayout = function(s, w, h)
        for i = 1, #self.CreatedButtons do
            local button = self.CreatedButtons[i];

            if (IsValid(button)) then
                button:SetPos(5, 5 + (35 * (i - 1)));
                button:SetSize(w - 11, 30)
            end
        end
    end

    self.OptionsHolder.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, 100);
        surface.DrawRect(0, 0, w, h);

        surface.SetDrawColor(Sublime.Colors.Outline);
        surface.DrawRect(w - 1, 0, 1, h);
    end

    if (Sublime.Config.ConfigAccess[self.Player:GetUserGroup()]) then
        net.Start("Sublime.RefreshSettings");
        net.SendToServer();
    end
end

function panel:PerformLayout(w, h)
    self.OptionsHolder:SetPos(0, 0);
    self.OptionsHolder:SetSize(150, h);
end

function panel:Think()
    if (not self.PostInitCalled) then
        self:PostInit();

        self.PostInitCalled = true;
    end
end

function panel:PostInit()
    self:CreateButtons();
end

function panel:SetWarningMessage()
    -- deprecated
end

function panel:Paint(w, h)
end
vgui.Register("Sublime.Options", panel, "EditablePanel");