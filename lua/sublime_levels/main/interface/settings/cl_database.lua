local panel = {};

local approach = math.Approach;

function panel:CreateCategory(category, data)
    local nextCategory = #self.Categories + 1;

    self.Categories[nextCategory] = self.ScrollPanel:Add("DPanel");
    local cat = self.Categories[nextCategory];

    cat.Items = {};
    cat.Name = category:gsub("^%l", string.upper);
    cat.Dropped = true;
    cat.Tall = 30 + (65 * table.Count(self.Categories));
    cat.FirstTall = cat.Tall;

    cat.Paint = function(panel, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
        
        Sublime:DrawTextOutlined(panel.Name, "Sublime.22", 5, 15, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
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

    cat.AddItem = function(name, button, func)
        local nextItem = #cat.Items + 1;

        cat.Items[nextItem] = cat:Add("DPanel");
        local setting = cat.Items[nextItem];

        setting.Paint = function(panel, w, h)
            draw.RoundedBox(8, 0, 0, w, h, self.CA(self.C.Outline, 100));

            Sublime:DrawTextOutlined(name, "Sublime.20", 10, 13, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
        end

        setting.PerformLayout = function(panel, w, h)
            if (IsValid(panel.Edit)) then
                panel.Edit:SetPos(10, h - 35);
                panel.Edit:SetSize(w - 20, 30)
            end
        end

        setting.Edit = setting:Add("DButton");
        setting.Edit:SetText("");
        setting.Edit.Paint = function(panel, w, h)
            draw.RoundedBox(8, 0, 0, w, h, Color(0, 0, 0, 100));
            Sublime:DrawTextOutlined(button, "Sublime.20", 10, h / 2, Sublime.Colors.White, Sublime.Colors.Black, TEXT_ALIGN_LEFT, true);
        end

        setting.Edit.DoClick = func;
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

    for k,v in ipairs(data) do
        cat.AddItem(v[1], v[2], v[3]);
    end

    return cat;
end

---
--- Init
---
function panel:Init()
    self.L  = Sublime.L;
    self.C  = Sublime.Colors;
    self.CA = ColorAlpha;

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
end

function panel:PostInit()
    self:CreateCategory("Databases", {
        {"Import data from SQLite to MySQL", "Start import", function()
            if (not Sublime.MySQL.Enabled) then
                Sublime.MakeNotification("MySQL", "MySQL is not enabled. In order for MySQL to function properly this module has to be enabled inside of the config file, the database 'sublime_levels' needs to be created manually and the credentials needs to be correct.");
                return;
            end

            local notification = Sublime.MakeNotification(self.L("skills_are_you_sure"), "Are you sure you want to convert your data from SQLite to MySQL? This will not append data, but the existing data will be deleted. This should only be done once.\nOnce the process is finished the server will do a map change to its current map.\nThis requires superadmin priviliges.", true);
            notification.DoAcceptClick = function()
                local notification1 = Sublime.MakeNotification("Server", "This should be done on a server where you are currently alone, do you want to continue?", true);
                notification1.DoAcceptClick = function()
                    net.Start("Sublime.ExportToMySQL")
                    net.SendToServer();
                end
            end
        end}

        /*{"Export data from MySQL to SQLite", "Start export", function()
            print("export");
        end},*/
    });
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
end

function panel:Think()
    if (not self.PostInitCalled) then
        self:PostInit();

        self.PostInitCalled = true;
    end
end

---
--- Paint
---
function panel:Paint(w, h)

end
vgui.Register("Sublime.DatabaseSettings", panel, "EditablePanel");

net.Receive("Sublime.ExportToMySQLResponse", function()
    Sublime.MakeNotification("Error", net.ReadString());
end);