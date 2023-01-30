local panel = {};
AccessorFunc(panel, "Player", "Player");

---
--- PostInit
---
function panel:PostInit()
    self:AddCMD(SUBLIME_GIVE_LEVELS, self.L("notification_give_level"), self.L("notification_give_level") .. "?", self.L("notification_give_level_desc"), self.L("notification_accept"), true);
    self:AddCMD(SUBLIME_TAKE_LEVELS, self.L("notification_take_level"), self.L("notification_take_level") .. "?", self.L("notification_take_level_desc"), self.L("notification_accept"), true);

    if (Sublime.Settings.Table["SERVER"]["other"].skills_enabled) then
        self:AddCMD(SUBLIME_GIVE_SKILLS, self.L("notification_give_skill"), self.L("notification_give_skill") .. "?", self.L("notification_give_skill_desc"), self.L("notification_accept"), true);
        self:AddCMD(SUBLIME_TAKE_SKILLS, self.L("notification_take_skill"), self.L("notification_take_skill") .. "?", self.L("notification_take_skill_desc"), self.L("notification_accept"), true);
    end

    self:AddCMD(SUBLIME_GIVE_XP, self.L("notification_give_experience"), self.L("notification_give_experience") .. "?", self.L("notification_give_experience_desc"), self.L("notification_accept"), true);
    self:AddCMD(SUBLIME_RESET_XP, self.L("notification_reset_experience"), self.L("notification_reset_experience") .. "?", self.L("notification_reset_experience_desc"), self.L("notification_accept"), false);

    self.PlayerNick         = self.Player:Nick();
    self.PlayerSteamID      = self.Player:SteamID64();
    self.Level              = self.Player:SL_GetLevel();
    self.Experience         = self.Player:SL_GetExperience();
    self.Needed             = self.Player:SL_GetNeededExperience();

	self.Avatar = self:Add("AvatarImage");
	self.Avatar:SetSteamID(self.PlayerSteamID, 184);

    self.PostInitCalled = true;
end

---
--- AddCMD
---
function panel:AddCMD(id, name, noti_header, noti_desc, noti_accept, useTextEntry)
    useTextEntry = useTextEntry or false;

    local nextCMD = #self.Cmds + 1;
    local r = math.random;

    self.Cmds[nextCMD] = self:Add("DButton");
    self.Cmds[nextCMD].Alpha = 100;
    self.Cmds[nextCMD]:SetText("");
    self.Cmds[nextCMD].Text = name;
    self.Cmds[nextCMD].Color = Color(r(1, 255), r(1, 255), r(1, 255));
    self.Cmds[nextCMD].Paint = function(panel, w, h)
        local color1 = self.CA(Sublime:LightenColor(panel.Color, 50), panel.Alpha);
        local color2 = self.CA(Sublime:DarkenColor(panel.Color, 25), panel.Alpha);

        Sublime:DrawRoundedGradient(panel, 8, 0, 0, w, h, color1, color2);
        Sublime:DrawTextOutlined(name, "Sublime.20", 5, h / 2, self.C.White, self.C.Black, TEXT_ALIGN_LEFT, true);

        panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {150, 2}, {100, 2});
    end

    self.Cmds[nextCMD].DoClick = function()
        local noti = Sublime.MakeNotification(noti_header, noti_desc, true, useTextEntry);
        noti.DoAcceptClick = function(s)
            if (useTextEntry) then
                local value = tonumber(noti:GetTextEntryValue());

                if (not isnumber(value) and useTextEntry) then
                    Sublime.MakeNotification(self.L("notification_invalid_character_title"), self.L("notification_invalid_character_des"), false);

                    return false;
                end

                if (not IsValid(self.Player)) then
                    Sublime.MakeNotification(self.L("notification_player_invalid_title"), self.L("notification_player_invalid_desc"), false);
                    
                    return;
                end

                if (id == SUBLIME_GIVE_LEVELS) then
                    local currentLevel = self.Player:GetNW2Int("sl_level", 1);
                    local after = currentLevel + value;
                    local max = tonumber(Sublime.Settings.Table["SERVER"]["other"]["max_level"]);

                    if (after > max) then
                        Sublime.MakeNotification(self.L("notification_max_level_title"), self.L("notification_max_level_desc", max - currentLevel));

                        return false;
                    end

                    if (value < 1) then
                        Sublime.MakeNotification(self.L("notification_invalid_value_title"), self.L("notification_invalid_value_desc"));

                        return false;
                    end
                end
                
                net.Start("Sublime.AdminAdjustData");
                    net.WriteUInt(id, 4);
                    net.WriteUInt(value, 32);
                    net.WriteString(self.PlayerSteamID);
                    net.WriteBool(false);
                net.SendToServer();
                
                Sublime.MakeNotification(self.L("notification_success_title"), self.L("notification_success_desc", self.PlayerNick));
            else
                net.Start("Sublime.AdminAdjustData");
                    net.WriteUInt(id, 4);
                    net.WriteUInt(0, 32);
                    net.WriteString(self.PlayerSteamID);
                    net.WriteBool(false);
                net.SendToServer();

                Sublime.MakeNotification(self.L("notification_success_title"), self.L("notification_success_desc", self.PlayerNick));
            end
        end
    end
end

---
--- Init
---
function panel:Init()
    self.L      = Sublime.L;
    self.Cmds   = {};
    self.C      = Sublime.Colors;
    self.CA     = ColorAlpha;

    self.HeaderColor = Color(0, 0, 0, 100);

    self:GetParent().CreatedPanel = self;
end

---
--- PerformLayout
---
function panel:PerformLayout(w, h)
    local combinedWidth = 0;
    local padding = 5;

    local i_AvatarWidth = 32;
    local i_AvatarHeight = 32;

    local i_AvatarPosX = 10;
    local i_AvatarPosY = 26 - (i_AvatarHeight / 2);

    self.Avatar:SetSize(i_AvatarWidth, i_AvatarHeight);
	self.Avatar:SetPos(i_AvatarPosX, i_AvatarPosY);

    for i = 1, #self.Cmds do
        local pnl = self.Cmds[i];

        if (IsValid(pnl)) then
            surface.SetFont("Sublime.20");
            local contents = surface.GetTextSize(pnl.Text) + (padding * 2);

            pnl:SetPos(padding + combinedWidth, 105);
            pnl:SetSize(contents, 30);

            combinedWidth = combinedWidth + (contents + padding);
        end
    end
end

---
--- Think
---
function panel:Think()
    if (not self.PostInitCalled and IsValid(self.Player) and self:GetWide() > 64) then
        self:PostInit();
    end
end

---
--- Paint
---
function panel:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 0);
    surface.DrawRect(0, 0, w, h);

    Sublime:DrawRoundedGradient(self, 8, 5, 5, w - 10, 95, self.CA(self.HeaderColor, 175), self.HeaderColor);
    
    surface.SetDrawColor(200, 200, 200, 100);
    surface.DrawRect(5, 50, w - 10, 1);

    Sublime:DrawTextOutlined(self.PlayerNick, "Sublime.20", 50, 26, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
    Sublime:DrawTextOutlined("Level: " .. self.Level, "Sublime.20", 10, 65, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
    Sublime:DrawTextOutlined("Experience: " .. string.Comma(self.Experience) .. "/" .. string.Comma(self.Needed), "Sublime.20", 10, 85, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
end
vgui.Register("Sublime.Profile", panel, "EditablePanel");

