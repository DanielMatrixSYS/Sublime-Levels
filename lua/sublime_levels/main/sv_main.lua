resource.AddWorkshop("1780556842");

util.AddNetworkString("Sublime.GetLeaderboardsData");
util.AddNetworkString("Sublime.SendLeaderboardsData");
util.AddNetworkString("Sublime.AdminAdjustData");
util.AddNetworkString("Sublime.ResetDatabase");
util.AddNetworkString("Sublime.DeleteUser");

local SQL = Sublime.GetSQL();

---
--- SL_Save
---
function Sublime.Player:SL_Save()
    local level             = self:GetNW2Int("sl_level", 1);
    local experience        = self:SL_GetInteger("experience", 0);
    local ability_points    = self:SL_GetInteger("ability_points", 0);
    local steamid           = self:SteamID64(); 

    Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Levels SET Level = '%s', Experience = '%s' WHERE SteamID = '%s'", level, experience, steamid));
    Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Skills SET Points = '%s' WHERE SteamID = '%s'", ability_points, steamid));

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
    
    local totalRows = sql.QueryValue("SELECT COUNT(*) FROM Sublime_Levels");
    
    if (not HasOwnData) then
        myData = sql.Query([[SELECT * FROM (SELECT ROW_NUMBER() OVER (ORDER BY TotalExperience DESC) Position, SteamID, Level, Experience, TotalExperience, NeededExperience, Name FROM Sublime_Levels)]]);
    end

    local data = sql.Query([[SELECT * FROM (SELECT ROW_NUMBER () OVER (ORDER BY TotalExperience DESC)
                                Position, SteamID, Level, Experience, TotalExperience, NeededExperience, Name FROM Sublime_Levels 
                                LIMIT ]] .. limit .. " OFFSET " .. offset .. ")");

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
                })

                break;
            end
        end
    end

    for i = 1, limit do
        local pData = data[i];

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
    
    ply.SublimeLeaderboardsDataCooldown = CurTime() + 1;
end);

local GIVE_LEVELS   = 0x1;
local TAKE_LEVELS   = 0x2;
local GIVE_SKILLS   = 0x3;
local TAKE_SKILLS   = 0x4;
local GIVE_XP       = 0x5;
local RESET_XP      = 0x6;

net.Receive("Sublime.AdminAdjustData", function(_, ply)
    if (not Sublime.Config.ConfigAccess[ply:GetUserGroup()]) then
        return;
    end

    local toAdjust  = net.ReadUInt(4);
    local value     = net.ReadUInt(32);
    local target    = net.ReadEntity();
    local steamid   = target:SteamID64();

    if (not IsValid(target)) then
        return;
    end

    if (toAdjust == GIVE_LEVELS) then
        local cLevel    = target:SL_GetLevel();
        local after     = cLevel + value;
        local max       = Sublime.Settings.Get("other", "max_level", "number");

        if (after > max) then
            return;
        end

        if (value < 1) then
            return;
        end

        target:SL_LevelUp(value);

        return;
    end

    if (toAdjust == TAKE_LEVELS) then
        local cLevel    = target:SL_GetLevel();
        local after     = cLevel - value;

        if (after < 0) then
            after = 1
        end

        target:SL_SetInteger("experience", 0);
        target:SetNW2Int("sl_level", after);
        target:SetNW2Int("sl_experience", 0);

        Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Levels SET Level = '%s', Experience = '0', NeededExperience = '%s' WHERE SteamID = '%s'", after, target:SL_GetNeededExperience(), target:SteamID64()));

        Sublime.Print("%s has taken %i levels from %s.", ply:Nick(), value, target:Nick());

        return;
    end

    if (toAdjust == GIVE_SKILLS) then
        target:SL_AddSkillPoint(value);

        return;
    end

    if (toAdjust == TAKE_SKILLS) then
        local sPoints   = target:SL_GetInteger("ability_points", 0);
        local after     = sPoints - value;

        if (after < 0) then
            after = 0;
        end

        target:SL_SetInteger("ability_points", after);

        Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Skills SET Points = '%s' WHERE SteamID = '%s'", after, target:SteamID64()));

        Sublime.Print("%s has now %i skill points to use.", target:Nick(), after);

        return;
    end

    if (toAdjust == GIVE_XP) then
        target:SL_AddExperience(value, "from an Admin.", true, false, true);

        return;
    end

    if (toAdjust == RESET_XP) then
        target:SL_SetInteger("experience", 0);
        target:SetNW2Int("sl_experience", 0);

        Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Levels SET Experience = '0' WHERE SteamID = '%s'", target:SteamID64()));
        Sublime.Print("%s has reset %s's experience.", ply:Nick(), target:Nick());

        return;
    end
end);

net.Receive("Sublime.ResetDatabase", function(_, ply)
    if (not ply:IsSuperAdmin()) then
        return;
    end

    sql.Query("DROP TABLE Sublime_Levels");
    sql.Query("DROP TABLE Sublime_Skills");
    sql.Query("DROP TABLE Sublime_Data");

    RunConsoleCommand("changelevel", game.GetMap());
end);

net.Receive("Sublime.DeleteUser", function(_, ply)
    if (not ply:IsSuperAdmin()) then
        return;
    end

    local steamid = net.ReadString();
    
    sql.Query("DELETE FROM Sublime_Levels WHERE SteamID = '" .. steamid .. "'");
    sql.Query("DELETE FROM Sublime_Skills WHERE SteamID = '" .. steamid .. "'");

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
                getName = getName:Replace("<meta name=\"description\" content=\"");
                getName = getName:Replace("SteamId.xyz\">", "");
                foundName = getName;

                if (foundName and foundName ~= "" and 
                foundName ~= "testing" and not foundName:find("is an online tool")) then
                    Sublime.Print("Name found: " .. foundName);

                    sql.Query(SQL:FormatSQL([[INSERT OR IGNORE INTO Sublime_Levels (SteamID, Level, Experience, TotalExperience, NeededExperience, Name) VALUES('%s', '1', '0', '0', '%i', '%s')]], steamid, 1575, foundName));
                end
            end,

            function(message)
                Sublime.Print("http.Fetch error in fill_leaderboards: " .. message);
            end
        )
    end
end);