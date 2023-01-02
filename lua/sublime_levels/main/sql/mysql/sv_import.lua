util.AddNetworkString("Sublime.ExportToMySQL");
util.AddNetworkString("Sublime.ExportToMySQLResponse");

local to = tonumber;

local function importSublimeLevels(steamid, level, experience, totalexperience, neededexperience, name)
    local prep = Sublime.MySQL.DB:prepare("INSERT IGNORE INTO Sublime_Levels (SteamID, Level, Experience, TotalExperience, NeededExperience, Name) VALUES(?, ?, ?, ?, ?, ?)");

    function prep:onSuccess(data)
        if (prep:affectedRows() > 0) then
            Sublime.Print("Successfully inserted rows from [importSublimeLevels]");
        end
    end

    function prep:onError(err)
        print("MySQL error in [importSublimeLevels]: " .. err);
    end

    prep:setString(1, steamid);
    prep:setNumber(2, to(level));
    prep:setNumber(3, to(experience));
    prep:setNumber(4, to(totalexperience));
    prep:setNumber(5, to(neededexperience));
    prep:setString(6, name);

    prep:start();
end

function Sublime.MySQL:StartImport()
    if (not Sublime.MySQL.Enabled) then
        return;
    end

    if (not Sublime.MySQL.DB:ping()) then
        Sublime.Print("Can not start importing, the database connection can not be found.");
        return;
    end

    Sublime.MySQL.ImportStarted = true;

    local SQL = Sublime.GetSQL();

    return true;
end

net.Receive("Sublime.ExportToMySQL", function(_, ply)
    if (not IsValid(ply) or not ply:IsSuperAdmin()) then
        return;
    end

    if (not Sublime.MySQL.DB:ping()) then
        net.Start("Sublime.ExportToMySQLResponse")
            net.WriteString("The MySQL connection can not be found. Ensure your MySQL server is up and the credentials are correct.");
        net.Send(ply);

        return;
    end

    Sublime.MySQL.ImportStarted = true;

    local prep = Sublime.MySQL.DB:prepare("DELETE FROM Sublime_Levels WHERE SteamID = ?");

    function prep:onSuccess()
        local sublime_levels = sql.Query("SELECT * FROM Sublime_Levels");

        for i = 1, #sublime_levels do
            local data = sublime_levels[i];
    
            if (data) then
                importSublimeLevels(data.SteamID, data.Level, data.Experience, data.TotalExperience, data.NeededExperience, data.Name)
            end
        end

        local sublime_data = sql.Query("SELECT ExperienceGained, LevelsGained FROM Sublime_Data");

        local prep3 = Sublime.MySQL.DB:query("UPDATE Sublime_Data SET ExperienceGained = " .. sublime_data[1].ExperienceGained .. ", LevelsGained = " .. sublime_data[1].LevelsGained .. " WHERE ID = 1");

        prep3:start();
    end

    prep:setString(1, ply:SteamID64());
    prep:start();

    local prep2 = Sublime.MySQL.DB:prepare("DELETE FROM Sublime_Skills WHERE SteamID = ?");

    function prep2:onSuccess()
        local sublime_skills = sql.Query("SELECT * FROM Sublime_Skills");

        for i = 1, #sublime_skills do
            local data = sublime_skills[i];
    
            if (data) then
                local prep4 = Sublime.MySQL.DB:prepare("INSERT IGNORE INTO Sublime_Skills (SteamID, Points, Points_Spent, Skill_Data) VALUES(?, ?, ?, ?)");

                prep4:setString(1, data.SteamID);
                prep4:setNumber(2, to(data.Points));
                prep4:setNumber(3, to(data.Points_Spent));
                prep4:setString(4, data.Skill_Data);

                prep4:start();
            end
        end
    end

    prep2:setString(1, ply:SteamID64());
    prep2:start();
end);