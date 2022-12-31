local panel = {};

local approach = math.Approach;

function panel:CreateCategory(category, data)
    local nextCategory  = #self.Categories + 1;
    local dataCount     = table.Count(data);

    self.Categories[nextCategory] = self.ScrollPanel:Add("DPanel");
    local cat = self.Categories[nextCategory];

    cat.Items       = {};
    cat.Name        = category
    cat.Dropped     = false;
    cat.Tall        = 30 + (65 * dataCount);
    cat.FirstTall   = cat.Tall;

    cat.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
        
        Sublime:DrawTextOutlined(panel.Name, "Sublime.22", 5, 14, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
    end

    cat.PerformLayout = function(panel, w, h)
        for i = 1, #panel.Items do
            local item = panel.Items[i];

            if (IsValid(item)) then
                local width     = w - 10;
                local height    = 60;

                if (item.xWidth and item.xWidth > 0) then
                    width = item.xWidth;
                end

                if (item.yHeight and item.yHeight > 0) then
                    height = item.yHeight 
                end

                item:SetPos(5, 30 + (65) * (i - 1));
                item:SetSize(width, height);
            end
        end

        panel.DropDown:SetPos(w - 30, 3);
        panel.DropDown:SetSize(24, 24);
    end

    cat.AddItem = function(name, value, ...)
        local nextItem      = #cat.Items + 1;
        local args          = {...};
        local panelToMake   = args[1] == nil and "DPanel" or args[1];

        cat.Items[nextItem] = cat:Add(panelToMake);
        local setting = cat.Items[nextItem];

        if (args[2] ~= nil and args[3] ~= nil) then
            setting.xWidth  = args[2];
            setting.yHeight = args[3];
        end

        setting.Paint = function(panel, w, h)
            if (args[4]) then
                args[4](panel, w, h)
            else
                draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, 100));

                Sublime:DrawTextOutlined(name, "Sublime.20", 10, 13, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
            end
        end

        setting.PerformLayout = function(panel, w, h)
            if (IsValid(panel.Edit)) then
                panel.Edit:SetPos(10, h - 35);
                panel.Edit:SetSize(w - 20, 30)
            end
        end

        if (panelToMake == "DPanel") then
            setting.Edit = setting:Add("DTextEntry");
            setting.Edit:SetDrawLanguageID(false);
            setting.Edit:SetFont("Sublime.18")
            setting.Edit.Paint = function(panel, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
                panel:DrawTextEntryText(self.C.Grey, self.C.Grey, self.C.Grey);
            end

            setting.Edit.OnEnter = function()
                local value = setting.Edit:GetValue();

                if (not value or value == "" or not isnumber(tonumber(value))) then
                    return;
                end
                
                //Sublime.Skills[name] = value;
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
                    
                    //Sublime.Settings.Table["SERVER"][category][name] = value;
                end 
            end

            //setting.Edit:SetValue(value);
        else
            setting.DoClick = args[3];
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

    cat.AddItem("Name", data.Name);
    cat.AddItem("Description", data.Description);
    cat.AddItem("Category", data.Category);
    cat.AddItem("Amount of buttons", data.ButtonAmount);
    cat.AddItem("Amount of points per button", data.AmountPerPoint);
    cat.AddItem("Enabled", data.Enabled);
    cat.AddItem("Save", "Save", "DButton", 0, 25, function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Sublime.Colors.Black);
        Sublime:DrawRoundedGradient(panel, 8, 1, 1, w - 2, h - 2, Sublime.Colors.Green, Sublime:DarkenColor(Sublime.Colors.Green, 50))
    end,

    //DoClick
    function()
        print("clicked");
    end);

    return cat;
end

function panel:CreateCategories(refresh)
    if (refresh) then
        self.ScrollPanel:Clear();
        table.Empty(self.Categories);

        self:AddResetButton();
    end
    
    for i = 1, #Sublime.Skills do
        local data = Sublime.Skills[i];

        self:CreateCategory(data.Name, data);
    end
end

function panel:AddResetButton()
    self.SetDefault = self.ScrollPanel:Add("DButton");
    self.SetDefault.Alpha = 50;
    self.SetDefault:SetText("");
    self.SetDefault.Paint = function(panel, w, h)
        local color1 = self.CA(Sublime:LightenColor(self.C.Red, 50), panel.Alpha);

        draw.RoundedBox(8, 0, 0, w, h, color1);
        Sublime:DrawTextOutlined(self.L("server_default"), "Sublime.20", w / 2, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_CENTER, true);
    
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
    //self:AddResetButton();
end

---
--- OnRemove
---
function panel:OnRemove()
    //net.Start("Sublime.SaveServerSideSettings")
        //net.WriteTable(Sublime.Settings.Table["SERVER"]);
    //net.SendToServer();
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
            local deducted  = item.DeductTall;
            local height    = item.Dropped and (30 + (65 * count)) or 30;

            if (item.Dropped) then
                height = height - 35
            end

            item:SetPos(5, yPos);
            item:SetSize((w - padding) - size, height);

            yPos = yPos + (height + padding);
        end
    end

    //self.SetDefault:SetPos(5, yPos);
    //self.SetDefault:SetSize((w - padding) - size, 30);
end

---
--- Paint
---
function panel:Paint(w, h)

end
vgui.Register("Sublime.OptionsSkills", panel, "EditablePanel");