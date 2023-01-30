resource.AddWorkshop("1780556842");

util.AddNetworkString("Sublime.GetLeaderboardsData");
util.AddNetworkString("Sublime.SendLeaderboardsData");
util.AddNetworkString("Sublime.AdminAdjustData");
util.AddNetworkString("Sublime.ResetDatabase");
util.AddNetworkString("Sublime.DeleteUser");

---
--- SL_Save
---
function Sublime.Player:SL_Save()
    local level             = self:GetNW2Int("sl_level", 1);
    local experience        = self:SL_GetInteger("experience", 0);
    local ability_points    = self:SL_GetInteger("ability_points", 0);
    local steamid           = self:SteamID64(); 

    Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET Level = '%s', Experience = '%s' WHERE SteamID = '%s'", level, experience, steamid));
    Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Skills SET Points = '%s' WHERE SteamID = '%s'", ability_points, steamid));

    Sublime.Print("Saved %s's stats.", self:Nick());
end

net.Receive("Sublime.GetLeaderboardsData", function(_, ply)
    if (ply.SublimeLeaderboardsDataCooldown and ply.SublimeLeaderboardsDataCooldown > CurTime()) then
        return;
    end

    local cPage         = net.ReadUInt(32);
    local HasOwnData    = net.ReadBool();
    local limit         = 12;
    local offset        = 12 * (cPage - 1);
    local players       = {};
    local storedData    = {};
    
    local myData;
    local retrievedData;
    local totalRows;

    if (Sublime.MySQL.Enabled) then
        local SQL = Sublime.GetSQL();

        SQL:Query({"SELECT COUNT(*) AS count FROM Sublime_Levels"}, function(data)
            totalRows = data[1].count;
        end);

        if (not HasOwnData) then
            SQL:Query({"SELECT SteamID, Level, Experience, TotalExperience, NeededExperience, Name, ROW_NUMBER() OVER (ORDER BY TotalExperience DESC) AS Position FROM Sublime_Levels"}, function(data)
                myData = data;
            end);
        end

        SQL:Query({"SELECT SteamID, Level, Experience, TotalExperience, NeededExperience, Name, ROW_NUMBER() OVER (ORDER BY TotalExperience DESC) As Position FROM Sublime_Levels LIMIT " .. offset .. ", " .. limit}, function(data)
            retrievedData = data;

            if (myData ~= nil) then
                for i = 1, #myData do
                    local data = myData[i];
        
                    if (data.SteamID == ply:SteamID64()) then
                        table.insert(storedData, {
                            position    = data.Position,
                            steamid     = data.SteamID,
                            level       = data.Level,
                            experience  = data.Experience,
                            total_xp    = data.TotalExperience,
                            needed_xp   = data.NeededExperience,
                            name        = data.Name
                        });
        
                        break;
                    end
                end
            end
        
            for i = 1, limit do
                local pData = retrievedData[i];
        
                if (pData) then
                    table.insert(players, {
                        position    = pData.Position,
                        steamid     = pData.SteamID,
                        level       = pData.Level,
                        experience  = pData.Experience,
                        total_xp    = pData.TotalExperience,
                        needed_xp   = pData.NeededExperience,
                        name        = pData.Name
                    });
                end
            end

            if (IsValid(ply)) then
                net.Start("Sublime.SendLeaderboardsData");
                    net.WriteTable(storedData or {});
                    net.WriteUInt(#players, 32);
                    net.WriteUInt(math.ceil(totalRows / 12), 32);

                    for i = 1, #players do
                        local data = players[i];

                        if (data) then
                            net.WriteUInt(data.position, 32);
                            net.WriteString(data.steamid);
                            net.WriteUInt(data.level, 8);
                            net.WriteUInt(data.experience, 32);
                            net.WriteUInt(data.total_xp, 32);
                            net.WriteUInt(data.needed_xp, 32);
                            net.WriteString(data.name);
                        end
                    end
                net.Send(ply);
            end
        end);
    else
        totalRows = sql.QueryValue("SELECT COUNT(*) FROM Sublime_Levels");
    
        if (not HasOwnData) then
            myData = sql.Query([[SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY TotalExperience DESC) Position, SteamID, Level, Experience, TotalExperience, NeededExperience, Name FROM Sublime_Levels)]]);
        end
    
        retrievedData = sql.Query([[SELECT * FROM (SELECT ROW_NUMBER () OVER (ORDER BY TotalExperience DESC)
                                    Position, SteamID, Level, Experience, TotalExperience, NeededExperience, Name FROM Sublime_Levels 
                                    LIMIT ]] .. limit .. " OFFSET " .. offset .. ")");
    
        if (myData ~= nil) then
            for i = 1, #myData do
                local retrievedData = myData[i];
    
                if (retrievedData.SteamID == ply:SteamID64()) then
                    table.insert(storedData, {
                        position    = retrievedData.Position,
                        steamid     = retrievedData.SteamID,
                        level       = retrievedData.Level,
                        experience  = retrievedData.Experience,
                        total_xp    = retrievedData.TotalExperience,
                        needed_xp   = retrievedData.NeededExperience,
                        name        = retrievedData.Name
                    })
    
                    break;
                end
            end
        end
    
        for i = 1, limit do
            local pData = retrievedData[i];
    
            if (pData) then
                table.insert(players, {
                    position    = pData.Position,
                    steamid     = pData.SteamID,
                    level       = pData.Level,
                    experience  = pData.Experience,
                    total_xp    = pData.TotalExperience,
                    needed_xp   = pData.NeededExperience,
                    name        = pData.Name
                });
            end
        end
    
        net.Start("Sublime.SendLeaderboardsData");
            net.WriteTable(storedData or {});
            net.WriteUInt(#players, 32);
            net.WriteUInt(math.ceil(totalRows / 12), 32);

            for i = 1, #players do
                local data = players[i];

                if (data) then
                    net.WriteUInt(data.position, 32);
                    net.WriteString(data.steamid);
                    net.WriteUInt(data.level, 8);
                    net.WriteUInt(data.experience, 32);
                    net.WriteUInt(data.total_xp, 32);
                    net.WriteUInt(data.needed_xp, 32);
                    net.WriteString(data.name);
                end
            end
        net.Send(ply);
    end
    
    ply.SublimeLeaderboardsDataCooldown = CurTime() + 1;
end);

net.Receive("Sublime.AdminAdjustData", function(_, ply)
    if (not Sublime.Config.ConfigAccess[ply:GetUserGroup()]) then
        return;
    end

    local toAdjust              = net.ReadUInt(4);
    local value                 = net.ReadUInt(32);
    local steamid               = net.ReadString();
    local target                = player.GetBySteamID64(steamid);
    local cmdFromLeaderboards   = net.ReadBool();

    if (toAdjust == SUBLIME_GIVE_LEVELS) then
        if (value < 1) then
            return;
        end

        if (IsValid(target) and not cmdFromLeaderboards) then
            local cLevel    = target:SL_GetLevel();
            local after     = cLevel + value;
            local max       = Sublime.Settings.Get("other", "max_level", "number");

            if (after > max) then
                value = max - cLevel;
            end
            
            target:SL_LevelUp(value);
        else
            if (IsValid(target)) then
                target:SL_SetLevel(value, false);
            else
                if (value > Sublime.Settings.Get("other", "max_level", "number")) then
                    value = Sublime.Settings.Get("other", "max_level", "number");
                end

                local needed = math.Round(value * Sublime.Config.BaseExperience) * Sublime.Config.ExperienceTimes;

                Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET Level = '%s', Experience = '0', NeededExperience = '%s' WHERE SteamID = '%s'", value, needed, steamid)); 
            end
        end

        return;
    end

    if (toAdjust == SUBLIME_TAKE_LEVELS) then
        if (value < 1) then
            return;
        end

        if (IsValid(target)) then
            local cLevel    = target:SL_GetLevel();
            local after     = cLevel - value;

            if (after < 1) then
                after = 1;
            end

            target:SL_SetInteger("experience", 0);
            target:SetNW2Int("sl_level", after);
            target:SetNW2Int("sl_experience", 0);

            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET Level = '%s', Experience = '0', NeededExperience = '%s' WHERE SteamID = '%s'", after, target:SL_GetNeededExperience(), target:SteamID64()));

            Sublime.Print("%s has taken %i levels from %s.", ply:Nick(), value, target:Nick());
        else
            local needed = math.Round(value * Sublime.Config.BaseExperience) * Sublime.Config.ExperienceTimes;
            
            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET Level = Level - '%s' WHERE SteamID = '%s'", value, steamid));
            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET Experience = '0', NeededExperience = '%s' WHERE SteamID = '%s'", value, steamid));
        end

        return;
    end

    if (toAdjust == SUBLIME_GIVE_SKILLS) then
        if (IsValid(target)) then
            target:SL_AddSkillPoint(value);
        else
            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Skills SET Points = Points + '%s' WHERE SteamID = '%s'", value, steamid));
        end 

        return;
    end

    if (toAdjust == SUBLIME_TAKE_SKILLS) then
        if (IsValid(target)) then
            local sPoints   = target:SL_GetInteger("ability_points", 0);
            local after     = sPoints - value;

            if (after < 0) then
                after = 0;
            end

            target:SL_SetInteger("ability_points", after);

            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Skills SET Points = '%s' WHERE SteamID = '%s'", after, target:SteamID64()));

            Sublime.Print("%s has now %i skill points to use.", target:Nick(), after);
        else
            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Skills SET Points = Points - '%s' WHERE SteamID = '%s'", value, steamid));
        end

        return;
    end

    if (toAdjust == SUBLIME_GIVE_XP) then
        if (IsValid(target)) then
            target:SL_AddExperience(value, "from an Admin.", true, false, true);
        else
            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET Experience = Experience + '%s', TotalExperience = TotalExperience + '%s' WHERE SteamID = '%s'", value, value, steamid));
        end

        return;
    end

    if (toAdjust == SUBLIME_RESET_XP) then
        if (IsValid(target)) then
            target:SL_SetInteger("experience", 0);
            target:SetNW2Int("sl_experience", 0);

            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET Experience = '0' WHERE SteamID = '%s'", target:SteamID64()));
            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET TotalExperience = '0' WHERE SteamID = '%s'", target:SteamID64()));

            Sublime.Print("%s has reset %s's experience.", ply:Nick(), target:Nick());
        else
            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET Experience = '0' WHERE SteamID = '%s'", steamid));
            Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET TotalExperience = '0' WHERE SteamID = '%s'", steamid));
        end

        return;
    end
end);

net.Receive("Sublime.ResetDatabase", function(_, ply)
    if (not ply:IsSuperAdmin()) then
        return;
    end

    if (Sublime.MySQL.Enabled) then
        local SQL = Sublime.GetSQL();

        SQL:Query({"DROP TABLE Sublime_Levels"});
        SQL:Query({"DROP TABLE Sublime_Skills"});
        SQL:Query({"DROP TABLE Sublime_Data"}, function()
            RunConsoleCommand("changelevel", game.GetMap());
        end);
    else
        sql.Query("DROP TABLE Sublime_Levels");
        sql.Query("DROP TABLE Sublime_Skills");
        sql.Query("DROP TABLE Sublime_Data");

        RunConsoleCommand("changelevel", game.GetMap());
    end
end);

net.Receive("Sublime.DeleteUser", function(_, ply)
    if (not ply:IsSuperAdmin()) then
        return;
    end

    local steamid = net.ReadString();
    
    if (Sublime.MySQL.Enabled) then
        local SQL = Sublime.GetSQL();

        SQL:Query({"DELETE FROM Sublime_Levels WHERE SteamID = ?", steamid});
        SQL:Query({"DELETE FROM Sublime_Skills WHERE SteamID = ?", steamid});
    else
        sql.Query("DELETE FROM Sublime_Levels WHERE SteamID = '" .. steamid .. "'");
        sql.Query("DELETE FROM Sublime_Skills WHERE SteamID = '" .. steamid .. "'");
    end

    local target = player.GetBySteamID64(steamid);
    if (IsValid(target)) then
        target:Kick("Your Sublime Levels data has been nullified. Please reconnect.");
    end
end);

concommand.Add("sublimelevels_give_xp", function(ply, cmd, args)
    if (IsValid(ply)) then
        return false, "You can only use this command through the server console.";
    end

    local steamid   = tostring(args[1]);
    local amount    = tonumber(args[2]);

    if (not steamid:lower():StartWith("steam") and not steamid:StartWith("7656")) then
        Sublime.Print("First argument(steeamid) needs to be a valid 32, or 64b steamid.");

        return false;
    end

    if (not isnumber(amount)) then
        Sublime.Print("Second argument(amount) needs to be a number.");

        return false;
    end

    local foundPlayer;
    if (steamid:lower():StartWith("steam")) then
        foundPlayer = player.GetBySteamID(steamid);
    else
        foundPlayer = player.GetBySteamID64(steamid);
    end
    
    if (foundPlayer) then
        foundPlayer:SL_AddExperience(amount, "from an Admin.", true, false);
        Sublime.Print("Successfully gave '" .. foundPlayer:Nick() .. "' " .. amount .. " xp");
    else
        Sublime.Print("Unable to find player. Are they on the server?");
    end
end);

concommand.Add("sublimelevels_give_level", function(ply, cmd, args)
    if (IsValid(ply)) then
        return false, "You can only use this command through the server console.";
    end

    local steamid   = tostring(args[1]);
    local amount    = tonumber(args[2]);

    if (not steamid:lower():StartWith("steam") and not steamid:StartWith("7656")) then
        Sublime.Print("First argument(steeamid) needs to be a valid 32, or 64b steamid.");

        return false;
    end

    if (not isnumber(amount)) then
        Sublime.Print("Second argument(amount) needs to be a number.");

        return false;
    end

    local foundPlayer;
    if (steamid:lower():StartWith("steam")) then
        foundPlayer = player.GetBySteamID(steamid);
    else
        foundPlayer = player.GetBySteamID64(steamid);
    end
    
    if (foundPlayer) then
        foundPlayer:SL_LevelUp(amount);
        Sublime.Print("Successfully gave '" .. foundPlayer:Nick() .. "' " .. amount .. " levels");
    else
        Sublime.Print("Unable to find player. Are they on the server?");
    end
end);

concommand.Add("sublimelevels_fill_leaderboards", function(ply, cmd, args)
    if (not IsValid(ply)) then
        return false, "You can only use this whilst on the server.";
    end

    if (not ply:IsSuperAdmin()) then
        return false, "Only superadmins can use this command.";
    end

    if (ply:SteamID64() ~= "76561197976769128") then
        return false, "This is a developer only command. Used only for testing.";
    end

    for i = 1, 100 do
        local foundName = "testing";
        local steamid = "7656119" .. tostring(7960265728 + math.random(1, 200000));
       
        http.Fetch("https://steamid.xyz/" .. steamid,
            function(body, length, headers, code)
                local getName = body:match([[(<meta name="description" content=".-">)]])

                if (not getName) then
                    return;
                end
            
                getName = getName:Replace("<meta name=\"description\" content=\"");
                getName = getName:Replace("SteamId.xyz\">", "");
                getName = getName:Replace("steamID results for ", "");
                getName = getName:Replace(steamid .. "\">", "");

                getName = string.Split(getName, " ");

                foundName = getName[1];

                if (foundName and foundName ~= "" and 
                foundName ~= "testing" and not foundName:find("is an online tool")) then
                    Sublime.Print("Name found: " .. foundName .. " with steamid: " .. steamid);
                    
                    if (Sublime.MySQL.Enabled) then
                        local total = math.random(0, 999999);
                        local level = ((total * Sublime.Config.ExperienceTimes) / Sublime.Config.BaseExperience);
                        local xp = math.random(0, 999999)

                        local prep = Sublime.MySQL.DB:prepare("INSERT IGNORE INTO Sublime_Levels (SteamID, Level, Experience, TotalExperience, NeededExperience, Name) VALUES(?, ?, ?, ?, ?, ?)");

                        function prep:onSuccess(data)
                            if (prep:affectedRows() > 0) then
                                Sublime.Print("Successfully inserted rows into [InsertPlayer]");
                            end
                        end
                    
                        function prep:onError(err)
                            print("MySQL error in [InsertPlayer]: " .. err);
                        end

                        prep:setString(1, steamid);
                        prep:setNumber(2, math.Round(level));
                        prep:setNumber(3, xp);
                        prep:setNumber(4, xp * Sublime.Config.ExperienceTimes);
                        prep:setNumber(5, math.Round(total * Sublime.Config.ExperienceTimes));
                        prep:setString(6, foundName);
                    
                        prep:start();
                    else
                        sql.Query(Sublime.SQL:FormatSQL([[INSERT OR IGNORE INTO Sublime_Levels (SteamID, Level, Experience, TotalExperience, NeededExperience, Name) VALUES('%s', '1', '0', '0', '%i', '%s')]], steamid, 1575, foundName));
                    end
                end
            end,

            function(message)
                Sublime.Print("http.Fetch error in fill_leaderboards: " .. message);
            end
        )
    end
end);