local path          = Sublime.GetCurrentPath();
local data          = {};
local localData     = {}
local panel         = {};
local panelRefrence = nil;
local maxPages      = 1;
local comma         = string.Comma;
local approach      = math.Approach;

-- Colors
local mainOffsetColor   = Color(34, 44, 44);
local otherOffsetColor  = Color(45, 105, 99);

local leaderboardColors = {
    [1] = Color(255, 215, 0, 100),
    [2] = Color(215, 215, 215, 100),
    [3] = Color(106, 56, 5, 100)
}

local leaderboardSizes = {
    [1] = 45,
    [2] = 40,
    [3] = 35
}

local leaderboardMaskSizes = {
    [1] = 30,
    [2] = 27,
    [3] = 24
}

local leaderboardFontSises = {
    [1] = "24",
    [2] = "20"
}

function panel:AddPlayerToLeaderboard(parent, steamid, position, name, level, experience, needed, total_xp)
    local nextPlayer    = #parent.Players + 1;
    local tall          = leaderboardSizes[position] or 30;
    local fontSize      = leaderboardFontSises[position] or "18";

    local name  = steamid == LocalPlayer():SteamID64() and name .. " (You)" or name;
    local color = steamid == LocalPlayer():SteamID64() and Sublime.Colors.Green or Sublime.Colors.White;

    local leaderboardColor  = leaderboardColors[position] or self.CA(self.C.Outline, 50);
    local outlineColor      = self.CA(self.C.Black, 0);

    parent.Players[nextPlayer] = parent:Add("DPanel");
    parent.Players[nextPlayer]:SetPos(5, self.ChildPos);
    parent.Players[nextPlayer]:SetSize(parent:GetWide() - 10, tall);
    parent.Players[nextPlayer].MyColorAlpha = not self.InitAnimation and 0 - math.max((nextPlayer * 5), 0) or 100;
    parent.Players[nextPlayer].TextColorAlpha = not self.InitAnimation and 0 - math.max((nextPlayer * 5), 0) or 175;
    parent.Players[nextPlayer].PerformLayout = function(s, w, h)
        if (IsValid(s.Avatar)) then
            s.Avatar:SetPos(41, (h / 2) - s.Avatar.MaskSize / 2);
            s.Avatar:SetSize(s.Avatar.MaskSize, s.Avatar.MaskSize);
        end
    end
    
    parent.Players[nextPlayer].Paint = function(s, w, h)
        outlineColor        = self.CA(self.C.Black, s.MyColorAlpha);
        leaderboardColor    = self.CA(leaderboardColor, s.MyColorAlpha);
        color               = self.CA(color, s.TextColorAlpha);
        
        if (position < 4) then
            Sublime:DrawMaterialOutline(5, (h / 2) - 16, 32, 32, Sublime.Materials["SL_Rank_1"], Color(leaderboardColor.r, leaderboardColor.g, leaderboardColor.b, math.Clamp(s.MyColorAlpha * 2, 0, 255)), Color(0, 0, 0, math.Clamp(s.MyColorAlpha, 0, 255)));   
            Sublime:DrawRoundedGradient(s, 8, 0, 0, w, h, Color(leaderboardColor.r, leaderboardColor.g, leaderboardColor.b, math.Clamp(s.MyColorAlpha, 0, 255)), Color(0, 0, 0, math.Clamp(s.MyColorAlpha, 0, 255)));

            if (s.TextColorAlpha >= 175) then
                color = self.CA(color, 255);
            end
        else
            draw.RoundedBox(8, 0, 0, w, h, leaderboardColor);

            Sublime:DrawTextOutlined(position, "Sublime." .. fontSize, 5, h / 2, color, outlineColor, TEXT_ALIGN_LEFT, true);
        end

        Sublime:DrawTextOutlined(name, "Sublime." .. fontSize, s.Avatar.MaskSize + 51, h / 2, color, outlineColor, TEXT_ALIGN_LEFT, true);
        Sublime:DrawTextOutlined(level, "Sublime." .. fontSize, 290, h / 2, color, outlineColor, TEXT_ALIGN_LEFT, true);
        Sublime:DrawTextOutlined(comma(experience) .. "/" .. comma(needed), "Sublime." .. fontSize, w - 334, h / 2, color, outlineColor, TEXT_ALIGN_LEFT, true);
        Sublime:DrawTextOutlined(comma(total_xp), "Sublime." .. fontSize, w - 5, h / 2, color, outlineColor, TEXT_ALIGN_RIGHT, true);

        if (s:IsHovered()) then
            s.MyColorAlpha = approach(s.MyColorAlpha, 200, 2);

            if (s.HoverTime < CurTime()) then
                Sublime:DrawPanelTip(s, "[RIGHT CLICK] to open options menu");
            end
        else
            s.MyColorAlpha = approach(s.MyColorAlpha, 100, 1);
            s.TextColorAlpha = approach(s.TextColorAlpha, 175, 1);
            s.HoverTime = CurTime() + 1;
        end

        leaderboardColor = self.CA(leaderboardColor, s.MyColorAlpha);
    end

    parent.Players[nextPlayer].OnMousePressed = function(ply, key)
        local localplayer = LocalPlayer();

        if (key == MOUSE_RIGHT) then
            Sublime:CreateDropDownMenu(name, {
                {
                    text = self.L("leaderboards_open_profile"),
                    tip = self.L("database_profile_tip"),
                    func = function()
                        gui.OpenURL("https://steamcommunity.com/profiles/" .. steamid);
                    end,

                    hasAccess = true
                },

                {
                    text = self.L("leaderboards_copy_steamid"),
                    tip = self.L("database_copy_steamid_tip"),
                    func = function()
                        SetClipboardText(steamid);
                    end,

                    hasAccess = true
                },

                {
                    text = self.L("leaderboards_set_level"),
                    tip = self.L("database_set_level_tip"),
                    func = function()
                        local notification = Sublime.MakeNotification(self.L("leaderboards_set_level"), self.L("leaderboards_set_level_desc", name), true, true);
                        
                        notification.DoAcceptClick = function(s)
                            local value = tonumber(notification:GetTextEntryValue());

                            if (not isnumber(value)) then
                                Sublime.MakeNotification(self.L("notification_invalid_character_title"), self.L("notification_invalid_character_des"), false);
            
                                return false;
                            end

                            net.Start("Sublime.AdminAdjustData");
                                net.WriteUInt(SUBLIME_GIVE_LEVELS, 4);
                                net.WriteUInt(value, 32);
                                net.WriteString(steamid);
                                net.WriteBool(true);
                            net.SendToServer();

                            level = value;
                        end
                    end,

                    hasAccess = localplayer:IsSuperAdmin()
                },

                {
                    text = self.L("leaderboards_give_exp"),
                    tip = self.L("database_give_xp_tip"),
                    func = function()
                        local notification = Sublime.MakeNotification(self.L("notification_give_experience"), self.L("leaderboards_give_xp", name), true, true);
                        
                        notification.DoAcceptClick = function(s)
                            local value = tonumber(notification:GetTextEntryValue());

                            if (not isnumber(value)) then
                                Sublime.MakeNotification(self.L("notification_invalid_character_title"), self.L("notification_invalid_character_des"), false);
            
                                return false;
                            end

                            net.Start("Sublime.AdminAdjustData");
                                net.WriteUInt(SUBLIME_GIVE_XP, 4);
                                net.WriteUInt(value, 32);
                                net.WriteString(steamid);
                                net.WriteBool(true);
                            net.SendToServer();

                            experience = comma(experience + value);
                        end
                    end,

                    hasAccess = localplayer:IsSuperAdmin()
                },

                {
                    text = self.L("leaderboards_give_skill"),
                    tip = self.L("database_give_skill_tip"),
                    func = function()
                        local notification = Sublime.MakeNotification(self.L("notification_give_skill"), self.L("leaderboards_give_skill_desc", name), true, true);
                        
                        notification.DoAcceptClick = function(s)
                            local value = tonumber(notification:GetTextEntryValue());

                            if (not isnumber(value)) then
                                Sublime.MakeNotification(self.L("notification_invalid_character_title"), self.L("notification_invalid_character_des"), false);
            
                                return false;
                            end

                            net.Start("Sublime.AdminAdjustData");
                                net.WriteUInt(SUBLIME_GIVE_SKILLS, 4);
                                net.WriteUInt(value, 32);
                                net.WriteString(steamid);
                                net.WriteBool(true);
                            net.SendToServer();
                        end
                    end,

                    hasAccess = localplayer:IsSuperAdmin()
                },

                {
                    text = self.L("leaderboards_take_skill"),
                    tip = self.L("database_take_skill_tip"),
                    func = function()
                        local notification = Sublime.MakeNotification(self.L("notification_take_skill"), self.L("leaderboards_take_skill_desc", name), true, true);
                        
                        notification.DoAcceptClick = function(s)
                            local value = tonumber(notification:GetTextEntryValue());

                            if (not isnumber(value)) then
                                Sublime.MakeNotification(self.L("notification_invalid_character_title"), self.L("notification_invalid_character_des"), false);
            
                                return false;
                            end

                            net.Start("Sublime.AdminAdjustData");
                                net.WriteUInt(SUBLIME_TAKE_SKILLS, 4);
                                net.WriteUInt(value, 32);
                                net.WriteString(steamid);
                                net.WriteBool(true);
                            net.SendToServer();
                        end
                    end,
                    hasAccess = localplayer:IsSuperAdmin()
                },

                {
                    text = self.L("leaderboards_reset_user"),
                    tip = self.L("database_reset_user_tip"),
                    func = function()
                        local notification = Sublime.MakeNotification(self.L("database_delete"), self.L("leaderboards_reset_user_desc", name), true, false);
                        
                        notification.DoAcceptClick = function(s)
                            net.Start("Sublime.DeleteUser");
                                net.WriteString(steamid);
                            net.SendToServer();
 
                            parent.Players[nextPlayer]:Remove();
                        end
                    end,

                    hasAccess = localplayer:IsSuperAdmin()
                },

                {
                    text = self.L("leaderboards_change_user"),
                    tip = self.L("leaderboards_change_user_tip"),
                    func = function()
                        local notification = Sublime.MakeNotification(self.L("leaderboards_change_user_title"), self.L("leaderboards_change_user_desc", name), true, true);
                        
                        notification.DoAcceptClick = function(s)
                            local value = notification:GetTextEntryValue();

                            if (#value < 0 or #value > 32) then
                                Sublime.MakeNotification(self.L("notification_invalid_character_title"), self.L("notification_invalid_character_des"), false);
            
                                return false;
                            end

                            net.Start("Sublime.ChangeUsername");
                                net.WriteString(value);
                                net.WriteString(steamid);
                            net.SendToServer();

                            name = value;
                        end
                    end,

                    hasAccess = localplayer:IsSuperAdmin()
                },
            });
        end
    end

    parent.Players[nextPlayer].Avatar = parent.Players[nextPlayer]:Add("Sublime.AvatarCircleMask")
    parent.Players[nextPlayer].Avatar.MaskSize = leaderboardMaskSizes[position] or 21;
	parent.Players[nextPlayer].Avatar:SetSteamID(steamid);
	parent.Players[nextPlayer].Avatar:SetMaskSize(parent.Players[nextPlayer].Avatar.MaskSize / 2);
    parent.Players[nextPlayer].Avatar.Think = function()
        parent.Players[nextPlayer].Avatar:SetAlpha(parent.Players[nextPlayer].MyColorAlpha * 2.55);
    end

    self.ChildPos = self.ChildPos + (tall + 5);
end

function panel:FillLeaderboard()
    local count = #data

    for i = 1, count do
        local pData = data[i];

        if (pData) then
            self:AddPlayerToLeaderboard(self.PlayerHolders, pData.steamid, pData.position, pData.name, pData.level, pData.experience, pData.needed_xp, pData.total_xp);
        end
    end

    self.InitAnimation = true;
end

function panel:RebuildLeaderboard()
    self.ChildPos = 5;
    
    for i = 1, #self.PlayerHolders.Players do
        local panel = self.PlayerHolders.Players[i];

        if (IsValid(panel)) then
            panel:Remove();
        end
    end

    table.Empty(self.PlayerHolders.Players);
    self:FillLeaderboard();
end

function panel:RequestData()
    net.Start("Sublime.GetLeaderboardsData")
        net.WriteUInt(self.Page, 32);
        net.WriteBool(self.HasOwnData);
    net.SendToServer();

    self.Player.Sublime_LeaderCooldown = CurTime() + 1;
    self.HasOwnData = true;
end

function panel:Init()
    self.Page       = 1;
    self.Player     = LocalPlayer();
    self.ShouldFill = false;
    self.L          = Sublime.L;
    self.C          = Sublime.Colors;
    self.CA         = ColorAlpha;
    self.ChildPos   = 5;
    self.HasOwnData = false;
    
    self.InitAnimation = false;

    if (self.Player.Sublime_LeaderCooldown) then
        if (self.Player.Sublime_LeaderCooldown <= CurTime()) then
            self:RequestData();
        else
            self.ShouldFill = true;
        end
    else
        self:RequestData();
    end

    self.PlayerHolders = self:Add("DPanel");
    self.PlayerHolders.Players = {};
    self.PlayerHolders.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
    end

    self.Next = self:Add("DButton");
    self.Next:SetText("");
    self.Next.Alpha = 100;
    self.Next.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, s.Alpha));

        surface.SetDrawColor(255, 255, 255);
        surface.SetMaterial(Sublime.Materials["SL_LeftArrow"]);
        surface.DrawTexturedRectRotated(w / 2, h / 2, 12, 12, 180);

        if (s:IsHovered()) then
            s.Alpha = approach(s.Alpha, 200, 4);
        else
            s.Alpha = approach(s.Alpha, 100, 2);
        end
    end

    self.Next.DoClick = function()
        if (self.Page >= maxPages or self.Player.Sublime_LeaderCooldown > CurTime()) then
            return;
        else
            self.Page = self.Page + 1;
        end

        self:RequestData();
    end

    self.Next.OnCursorEntered = function()
        surface.PlaySound("sublime_levels/button.mp3");
    end

    self.LastPage = self:Add("DButton");
    self.LastPage:SetText("");
    self.LastPage.Alpha = 100;
    self.LastPage.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, s.Alpha));

        surface.SetDrawColor(255, 255, 255);
        surface.SetMaterial(Sublime.Materials["SL_Upgrade"]);
        surface.DrawTexturedRectRotated(w / 2, h / 2, 12, 12, 270);

        if (s:IsHovered()) then
            s.Alpha = approach(s.Alpha, 200, 4);
        else
            s.Alpha = approach(s.Alpha, 100, 2);
        end
    end

    self.LastPage.DoClick = function()
        self.Page = maxPages;

        self:RequestData();
    end

    self.LastPage.OnCursorEntered = function()
        surface.PlaySound("sublime_levels/button.mp3");
    end

    self.Previous   = self:Add("DButton");
    self.Previous:SetText("");
    self.Previous.Alpha = 100;
    self.Previous.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, s.Alpha));

        surface.SetDrawColor(255, 255, 255);
        surface.SetMaterial(Sublime.Materials["SL_LeftArrow"]);
        surface.DrawTexturedRect((w / 2) - 6, (h / 2) - 6, 12, 12);

        if (s:IsHovered()) then
            s.Alpha = approach(s.Alpha, 200, 4);
        else
            s.Alpha = approach(s.Alpha, 100, 2);
        end
    end

    self.Previous.DoClick = function()
        if (self.Page <= 1 or self.Player.Sublime_LeaderCooldown > CurTime()) then
            return;
        else
            self.Page = self.Page - 1;
        end

        self:RequestData();
    end

    self.Previous.OnCursorEntered = function()
        surface.PlaySound("sublime_levels/button.mp3");
    end

    self.FirstPage = self:Add("DButton");
    self.FirstPage:SetText("");
    self.FirstPage.Alpha = 100;
    self.FirstPage.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, s.Alpha));

        surface.SetDrawColor(255, 255, 255);
        surface.SetMaterial(Sublime.Materials["SL_Upgrade"]);
        surface.DrawTexturedRectRotated(w / 2, h / 2, 12, 12, 90);

        if (s:IsHovered()) then
            s.Alpha = approach(s.Alpha, 200, 4);
        else
            s.Alpha = approach(s.Alpha, 100, 2);
        end
    end

    self.FirstPage.DoClick = function()
        self.Page = 1;

        self:RequestData();
    end

    self.FirstPage.OnCursorEntered = function()
        surface.PlaySound("sublime_levels/button.mp3");
    end

    self.MyInformation = self:Add("DPanel");
    self.MyInformation.HasUpdatedAvatar = false;
    self.MyInformation.Paint = function(s, w, h)
        Sublime:DrawRoundedGradient(s, 8, 0, 0, w, h, Sublime.Colors.Outline, Color(0, 0, 0, 100));

        if (next(localData)) then
            Sublime:DrawTextOutlined(localData[1].position, "Sublime.20", 15, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
            Sublime:DrawTextOutlined(localData[1].name, "Sublime.20", s.Avatar.MaskSize + 51, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
            Sublime:DrawTextOutlined(localData[1].level, "Sublime.20", 296, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
            Sublime:DrawTextOutlined(comma(localData[1].experience) .. "/" .. comma(localData[1].needed_xp), "Sublime.20", w - 345, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
            Sublime:DrawTextOutlined(comma(localData[1].total_xp), "Sublime.20", w - 15, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER);

            if (not s.HasUpdatedAvatar) then
                s.Avatar:SetSteamID(localData[1].steamid);
            end
        end
    end

    self.MyInformation.PerformLayout = function(s, w, h)
        if (IsValid(s.Avatar)) then
            s.Avatar:SetPos(46, (h / 2) - s.Avatar.MaskSize / 2);
            s.Avatar:SetSize(s.Avatar.MaskSize, s.Avatar.MaskSize);
        end
    end

    self.MyInformation.Avatar = self.MyInformation:Add("Sublime.AvatarCircleMask")
    self.MyInformation.Avatar.MaskSize = 21;
	self.MyInformation.Avatar:SetMaskSize(self.MyInformation.Avatar.MaskSize / 2);

    panelRefrence = self;
end

function panel:Think()
    if (self.ShouldFill and next(data) and self.PlayerHolders:GetWide() > 64) then
        self:FillLeaderboard();

        self.ShouldFill = false;
    end
end

function panel:PerformLayout(w, h)
    self.PlayerHolders:SetPos(5, 80);
    self.PlayerHolders:SetSize(w - 10, self.Page == 1 and h - 110 or h - 140);

    local stringWidth, stringHeight = surface.GetTextSize(self.Page .. "/" .. maxPages);
    stringWidth = stringWidth + 10;

    self.Next:SetPos((w / 2) - 8 + (stringWidth / 2) + 30, h - 25);
    self.Next:SetSize(20, 20);

    self.LastPage:SetPos((w / 2) - 8 + (stringWidth / 2) + 5, h - 25);
    self.LastPage:SetSize(20, 20);

    self.Previous:SetPos((w / 2) - 8 - (stringWidth / 2) - 50, h - 25);
    self.Previous:SetSize(20, 20);

    self.FirstPage:SetPos((w / 2) - 8 - (stringWidth / 2) - 25, h - 25);
    self.FirstPage:SetSize(20, 20);

    self.MyInformation:SetPos(5, 40);
    self.MyInformation:SetSize(w - 10, 35);
end

function panel:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 0);
    surface.DrawRect(0, 0, w, h);

    draw.RoundedBox(8, 5, 5, w - 10, 30, Color(0, 0, 0, 100));

    Sublime:DrawTextOutlined("#", "Sublime.22", 15, 18, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
    Sublime:DrawTextOutlined(self.L("leaderboards_player"), "Sublime.22", 50, 18, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
    Sublime:DrawTextOutlined(self.L("leaderboards_level"), "Sublime.22", 300, 18, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
    Sublime:DrawTextOutlined(self.L("leaderboards_experience"), "Sublime.22", w - 345, 18, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
    Sublime:DrawTextOutlined(self.L("leaderboards_t_experience"), "Sublime.22", w - 15, 18, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER);

    -- Leaderboard Pages.
    local stringWidth, stringHeight = surface.GetTextSize(self.Page .. "/" .. maxPages);
    stringWidth = stringWidth + 10;

    draw.RoundedBox(8, (w / 2) - 9 - (stringWidth / 2), h - (16 + (stringHeight / 2)), stringWidth, stringHeight, Sublime.Colors.Black);
    Sublime:DrawTextOutlined(self.Page .. "/" .. maxPages, "Sublime.18", (w / 2) - 9, h - 16, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);
end
vgui.Register("Sublime.Leaderboards", panel, "EditablePanel");

hook.Add("Sublime.LeaderboardsDataRefreshed", path, function(newData, myData, max)
    if (next(myData)) then
        localData = myData;
    end

    data = newData;
    maxPages = max;

    if (IsValid(panelRefrence)) then
        panelRefrence:RebuildLeaderboard();
        panelRefrence:InvalidateLayout(true);
    end
end);