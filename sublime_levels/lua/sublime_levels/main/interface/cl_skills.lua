--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local panel = {};
local approach = math.Approach;

---
--- Init
---
function panel:Init()
    self.L          = Sublime.L;
    self.Player     = LocalPlayer();
    self.C          = Sublime.Colors;
    self.CA         = ColorAlpha;
    self.Categories = {};

    self.ScrollPanel = self:Add("DScrollPanel");
    local vBar = self.ScrollPanel:GetVBar();

    vBar:SetHideButtons(true);
    
    vBar.Color = Color(0, 0, 0, 50);
    vBar.Paint = function(panel, w, h)
        draw.RoundedBox(8, 2, 0, w - 4, h, panel.Color);    
    end

    vBar.btnGrip.Alpha = 25;
    vBar.btnGrip.Paint = function(panel, w, h)
        draw.RoundedBox(8, 2, 0, w - 4, h, self.C.Outline);

        panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {75, 2}, {25, 2}, panel:GetParent().Dragging); 
    end  

    for i = 1, #Sublime.Skills do
        local data          = Sublime.Skills[i];
        local category      = data.Category;
        local enabled       = data.Enabled;
        local exists, cat   = self:CategoryExists(category);

        if (not exists) then
            local first = i == 1;

            cat = self:CreateCategory(category, first);
        end

        if (enabled) then
            self:CreateSkill(cat, data);
        end
    end

    self.Reset = self.ScrollPanel:Add("DButton");
    self.Reset:SetText("");
    self.Reset:SetCursor("arrow");

    self.Reset.Alpha = 50;

    self.Reset.Paint = function(panel, w, h)
        local color1 = self.CA(Sublime:LightenColor(self.C.Red, 50), panel.Alpha);

        draw.RoundedBox(8, 0, 0, w, h, color1);
        Sublime:DrawTextOutlined("Reset Skills", "Sublime.14", w / 2, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);
    
        panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {100, 2}, {50, 2});
    end

    self.Reset.DoClick = function()
        local level = self.Player:SL_GetLevel();

        if (level > 1) then
            local noti = Sublime.MakeNotification("Are you sure?", "Are you sure you want to reset your skills?\nThis can't be undone.", true);
            noti.DoAcceptClick = function()
                net.Start("Sublime.ResetSkills");
                net.SendToServer();
            end
        else
            Sublime.MakeNotification("Unable", "You have to level up first.");
        end
    end
end

function panel:CategoryExists(check)
    for i = 1, #self.Categories do
        local category = self.Categories[i];

        if (IsValid(category) and category.Name == check) then
            return true, category;
        end
    end

    return false;
end

function panel:CreateSkill(category, data)
    if (not IsValid(category)) then
        return false;
    end

    local nextSkill = #category.Skills + 1;

    category.Skills[nextSkill] = category:Add("DPanel");
    local skill = category.Skills[nextSkill];

    local name      = data.Name;
    local desc      = data.Description;
    local id        = data.Identifier; 
    local amount    = data.ButtonAmount;

    local unlockSize    = 28;
    local iconSize      = 16;

    local skillAmount   = self.Player:SL_GetInteger(id);
    local unlocked      = skillAmount >= amount;
    local nextUnlock    = skillAmount + 1;

    skill.Paint = function(panel, w, h)
        draw.RoundedBoxEx(8, 0, 0, w, h, self.CA(self.C.Outline, 50), false, false, true, true);

        surface.SetDrawColor(self.C.Outline);
        surface.DrawRect(0, 25, w, 1);

        skillAmount = self.Player:SL_GetInteger(id);

        Sublime:DrawTextOutlined(name .. " - " .. skillAmount .. "/" .. amount, "Sublime.20", 5, 13, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);

        for i = 1, amount do
            unlocked    = skillAmount >= i;
            nextUnlock  = skillAmount + 1;

            local unlockAble    = nextUnlock == i;
            local color         = (unlocked or unlockAble) and self.C.Green or self.C.Red;

            surface.SetDrawColor(color)
            surface.DrawOutlinedRect(5 + (unlockSize + 5) * (i - 1), h - (unlockSize + 3), unlockSize, unlockSize);

            local material = (unlocked and Sublime.Materials["SL_Acquired"] or unlockAble and Sublime.Materials["SL_Unlocked"]) or Sublime.Materials["SL_Locked"];
            Sublime:DrawMaterialOutline((5 + (iconSize / 2) - 2) + ((unlockSize) + 5) * (i - 1), h - (unlockSize + 3) + ((iconSize / 2) - 2), 16, 16, material, self.C.Black, self.C.White);
        end
    end

    skill.PerformLayout = function(panel, w, h)
        if (IsValid(panel.Upgrade)) then
            panel.Upgrade:SetPos(w - 105, h - 31);
            panel.Upgrade:SetSize(100, 28);
        end

        panel.Help:SetPos(w - 21, 1);
        panel.Help:SetSize(20, 20);
    end

    skill.Think = function()
        if (nextUnlock <= amount) then
            if (not skill.Upgrade:IsVisible()) then
                skill.Upgrade:SetVisible(true);
            end
        else
            if (skill.Upgrade:IsVisible()) then
                skill.Upgrade:SetVisible(false);
            end
        end
    end

    skill.Upgrade = skill:Add("DButton");
    skill.Upgrade:SetText("")
    skill.Upgrade:SetCursor("arrow");

    skill.Upgrade.Alpha = 100;
    skill.Upgrade.Cooldown = CurTime();

    skill.Upgrade.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, panel.Alpha));
        
        Sublime:DrawTextOutlined("Upgrade", "Sublime.14", 31, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER);
        panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {200, 4}, {100, 2});
    end

    skill.Upgrade.DoClick = function(panel)
        if (panel.Cooldown >= CurTime()) then
            return;
        end

        local points = self.Player:SL_GetAbilityPoints();
        if (points > 0) then
            local noti = Sublime.MakeNotification("Are you sure?", "Are you sure you want to upgrade " .. data.Name .. "?", true);
            noti.DoAcceptClick = function()
                net.Start("Sublime.UpgradeSkill");
                    net.WriteString(id);
                net.SendToServer();
            end
        else
            Sublime.MakeNotification("Unable", "You don't have enough skill points to upgrade this skill.");
        end

        panel.Cooldown = CurTime() + 1;
    end

    skill.Help = skill:Add("DButton");
    skill.Help:SetText("");
    skill.Help:SetCursor("arrow");
    
    skill.Help.Paint = function(panel, w, h)
        Sublime:DrawMaterialOutline((w - iconSize) - 5, 4, iconSize, iconSize, Sublime.Materials["SL_Help"], self.C.Black, self.C.White);

        if (panel:IsHovered()) then
            Sublime:DrawPanelTip(panel, desc);
        end
    end

    return true;
end

function panel:CategoryCount(category)
    local count = 0;

    for i = 1, #Sublime.Skills do
        local data      = Sublime.Skills[i];
        local cat       = data.Category;
        local enabled   = data.Enabled;

        if (enabled and category == cat) then
            count = count + 1;
        end
    end
    
    return count;
end

function panel:CreateCategory(category, first)
    local nextCategory = #self.Categories + 1;
    local itemCount = self:CategoryCount(category);

    self.Categories[nextCategory] = self.ScrollPanel:Add("DPanel");
    local cat = self.Categories[nextCategory];

    cat.Skills = {};
    cat.Name = category;
    cat.Dropped = true;
    cat.Tall = 30 + (65 * itemCount);
    cat.FirstTall = cat.Tall;

    cat.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
        
        Sublime:DrawTextOutlined(category, "Sublime.18", 5, 15, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);

        if (first) then
            Sublime:DrawTextOutlined(self.L("skills_available", self.Player:SL_GetInteger("ability_points")), "Sublime.20", w / 2, 15, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);
        end
    end

    cat.PerformLayout = function(panel, w, h)
        for i = 1, #panel.Skills do
            local skill = panel.Skills[i];

            if (IsValid(skill)) then
                skill:SetPos(5, 30 + 65 * (i - 1));
                skill:SetSize(w - 10, 60);
            end
        end

        panel.DropDown:SetPos(w - 30, 3);
        panel.DropDown:SetSize(24, 24);
    end

    cat.DropDown = cat:Add("DButton");
    cat.DropDown:SetText("");
    cat.DropDown:SetCursor("arrow");

    cat.DropDown.IconSize = 18;
    cat.DropDown.CurrentRotation = 90;

    cat.DropDown.Paint = function(panel, w, h)
        Sublime:DrawMaterialRotatedOutline(w / 2, h / 2, panel.IconSize, panel.IconSize, Sublime.Materials["SL_LeftArrow"], self.C.Black, self.C.White, panel.CurrentRotation);
        
        if (cat.Dropped) then
            if (panel.CurrentRotation > 90) then
                panel.CurrentRotation = approach(panel.CurrentRotation, 90, 4);
            end
        else
            if (panel.CurrentRotation < 180) then
                panel.CurrentRotation = approach(panel.CurrentRotation, 180, 4);
            end
        end
    end

    cat.DropDown.DoClick = function()
        cat.Dropped = not cat.Dropped;

        self:InvalidateLayout(false);
    end

    return cat;
end

---
--- PerformLayout
---
function panel:PerformLayout(w, h)
    self.ScrollPanel:SetPos(0, 5);
    self.ScrollPanel:SetSize(w, h - 10);

    local yPos      = 0;
    local size      = self.ScrollPanel:GetVBar().Enabled and 20 or 10
    local padding   = 5;

    for i = 1, #self.Categories do
        local item = self.Categories[i];

        if (IsValid(item)) then

            local count     = table.Count(item.Skills);
            local height    = item.Dropped and (30 + (65 * count)) or 30;

            item:SetPos(5, yPos);
            item:SetSize((w - padding) - size, height);

            yPos = yPos + (height + padding);
        end
    end

    self.Reset:SetPos(5, yPos);
    self.Reset:SetSize((w - padding) - size, 30);
end

---
--- Think
---
function panel:Think()
    if (not self.HasCalledPostInit and self:GetWide() > 64) then
        self:PostInit();

        self.HasCalledPostInit = true;
    end
end

---
--- PostInit
---
function panel:PostInit()

end

---
--- Paint
---
function panel:Paint(w, h)
    return true;
end
vgui.Register("Sublime.Skills", panel, "EditablePanel");

