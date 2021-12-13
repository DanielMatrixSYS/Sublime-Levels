--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local panel = {};

local approach = math.Approach;

function panel:CreateCategory(category, data)
    local nextCategory = #self.Categories + 1;
    local dataCount = table.Count(data);

    self.Categories[nextCategory] = self.ScrollPanel:Add("DPanel");
    local cat = self.Categories[nextCategory];

    cat.Items = {};
    cat.Name = self.L("server_" .. category)
    cat.Dropped = true;
    cat.Tall = 30 + (65 * dataCount);
    cat.FirstTall = cat.Tall;

    cat.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
        
        Sublime:DrawTextOutlined(panel.Name, "Sublime.18", 5, 15, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
    end

    cat.PerformLayout = function(panel, w, h)
        for i = 1, #panel.Items do
            local item = panel.Items[i];

            if (IsValid(item)) then
                item:SetPos(5, 30 + 65 * (i - 1));
                item:SetSize(w - 10, 60);
            end
        end

        panel.DropDown:SetPos(w - 30, 3);
        panel.DropDown:SetSize(24, 24);
    end

    cat.AddItem = function(name, value)
        local nextItem = #cat.Items + 1;

        cat.Items[nextItem] = cat:Add("DPanel");
        local setting = cat.Items[nextItem];

        setting.Paint = function(panel, w, h)
            draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, 100));

            Sublime:DrawTextOutlined(self.L(name), "Sublime.20", 10, 13, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
        end

        setting.PerformLayout = function(panel, w, h)
            if (IsValid(panel.Edit)) then
                panel.Edit:SetPos(10, h - 35);
                panel.Edit:SetSize(w - 20, 30)
            end
        end

        if (isbool(value) or (category == "interface" and name == "menu_open")) then
            setting.Edit = setting:Add("DButton");
            setting.Edit:SetText("");
            setting.Edit:SetCursor("arrow");

            setting.Edit.Alpha = 100;
            setting.Edit.Enabled = value;
            setting.Edit.Editing = false;

            if (isnumber(value)) then
                self.Key = value;
                self.KeyPanel = setting.Edit;
            end

            setting.Edit.Paint = function(panel, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, panel.Alpha));

                panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {150, 2}, {100, 2});

                local str, color = "Unknown", self.C.White;

                if (isnumber(value) and self.Key) then
                    str   = input.GetKeyName(self.Key):upper();
                    color = self.C.White;
                else
                    str   = panel.Enabled and "Yes" or "No";
                    color = panel.Enabled and self.C.Green or self.C.Red;
                end

                if (panel.Editing) then
                    Sublime:DrawTextOutlined("PRESS A KEY", "Sublime.14", w / 2, h / 2, color, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);
                else
                    Sublime:DrawTextOutlined(str, "Sublime.14", w / 2, h / 2, color, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);
                end
            end

            setting.Edit.DoClick = function(panel)
                if (isnumber(value)) then
                    input.StartKeyTrapping()

                    panel.Editing = true;
                    self.Trapping = true;
                else
                    panel.Enabled = not panel.Enabled;
                    Sublime.Settings.Table["SERVER"][category][name] = panel.Enabled;
                end
            end
        else
            setting.Edit = setting:Add("DTextEntry");
            setting.Edit:SetDrawLanguageID(false);
            setting.Edit.Paint = function(panel, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
                panel:DrawTextEntryText(self.C.Grey, self.C.Grey, self.C.Grey);
            end

            setting.Edit.OnEnter = function()
                local value = setting.Edit:GetValue();

                if (not value or value == "" or not isnumber(tonumber(value))) then
                    return;
                end
                
                Sublime.Settings.Table["SERVER"][category][name] = value;
            end

            setting.Edit.OnLoseFocus = function(panel)
                local value = panel:GetValue();
                local currentType = isnumber(tonumber(panel:GetValue()));

                if (not currentType) then
                    currentType = "string";
                else
                    currentType = "number";
                end

                if (value ~= "") then
                    if (currentType == "number" and not isnumber(tonumber(value))) then
                        return;
                    end
                    
                    Sublime.Settings.Table["SERVER"][category][name] = value;
                end 
            end


            setting.Edit:SetValue(value);
        end
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

    for k, v in pairs(data) do
        cat.AddItem(k, v);
    end

    return cat;
end

function panel:CreateCategories(refresh)
    if (refresh) then
        self.ScrollPanel:Clear();
        table.Empty(self.Categories);

        self:AddResetButton();
    end

    self:CreateCategory("kills", Sublime.Settings.Table["SERVER"]["kills"]);
    
    for category, data in pairs(Sublime.Settings.Table["SERVER"]) do
        local temp_category = category;

        if (temp_category == "ttt") then
            temp_category = "terrortown"
        end

        if (temp_category ~= "kills" and temp_category == Sublime.GetCurrentGamemode() and temp_category ~= "other") then
            self:CreateCategory(category, data)
        end
    end

    self:CreateCategory("other", Sublime.Settings.Table["SERVER"]["other"]);
end

function panel:AddResetButton()
    self.SetDefault = self.ScrollPanel:Add("DButton");
    self.SetDefault.Alpha = 50;
    self.SetDefault:SetText("");
    self.SetDefault.Paint = function(panel, w, h)
        local color1 = self.CA(Sublime:LightenColor(self.C.Red, 50), panel.Alpha);

        draw.RoundedBox(8, 0, 0, w, h, color1);
        Sublime:DrawTextOutlined(self.L("server_default"), "Sublime.14", w / 2, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);
    
        panel.Alpha = Sublime:DoHoverAnim(panel, panel.Alpha, {100, 2}, {50, 2});
    end
    
    self.SetDefault.DoClick = function()
        net.Start("Sublime.ResetServerSettings");
        net.SendToServer();

        self:GetParent():GetParent():Remove();

        chat.AddText(Sublime.Colors.Red, "[Sublime Levels]", Sublime.Colors.White, ": ", "You have successfully reset the server settings.");
    end
end

---
--- Init
---
function panel:Init()
    self.L  = Sublime.L;
    self.C  = Sublime.Colors;
    self.CA = ColorAlpha;

    self.Key = 0;
    self.KeyPanel = nil;

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

    self:CreateCategories();
    self:AddResetButton();
end

---
--- OnRemove
---
function panel:OnRemove()
    net.Start("Sublime.SaveServerSideSettings")
        net.WriteTable(Sublime.Settings.Table["SERVER"]);
    net.SendToServer();
end

---
--- PerformLayout
---
function panel:PerformLayout(w, h)
    self.ScrollPanel:SetPos(0, 0);
    self.ScrollPanel:SetSize(w, h - 5);

    local yPos      = 5;
    local size      = self.ScrollPanel:GetVBar().Enabled and 20 or 10
    local padding   = 5;

    for i = 1, #self.Categories do
        local item = self.Categories[i];

        if (IsValid(item)) then

            local count     = table.Count(item.Items);
            local height    = item.Dropped and (30 + (65 * count)) or 30;

            item:SetPos(5, yPos);
            item:SetSize((w - padding) - size, height);

            yPos = yPos + (height + padding);
        end
    end

    self.SetDefault:SetPos(5, yPos);
    self.SetDefault:SetSize((w - padding) - size, 30);
end

---
--- Paint
---
function panel:Paint(w, h)

end
vgui.Register("Sublime.OptionsServer", panel, "EditablePanel");