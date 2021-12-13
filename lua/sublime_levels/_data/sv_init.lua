--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local SQL   = {};
local path  = Sublime.GetCurrentPath();

---
--- CreateTables
---
function SQL:CreateTables()
    if (not sql.TableExists("Sublime_Levels")) then
        if (sql.Query([[CREATE TABLE Sublime_Levels (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            SteamID VARCHAR(17),
            Level INTEGER,
            Experience INTEGER,
            TotalExperience INTEGER,
            NeededExperience INTEGER,
            Name VARCHAR(32),
            Unique(SteamID)
        );]]) == false) then
            Sublime.Print("SQL Error: %s", sql.LastError());
        else
            Sublime.Print("Successfully created sql table: Sublime_Levels");
        end
    end

    if (not sql.TableExists("Sublime_Skills")) then
        if (sql.Query([[CREATE TABLE Sublime_Skills (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            SteamID VARCHAR(17),
            Points INTEGER,
            Points_Spent INTEGER,
            Skill_Data TEXT,
            Unique(SteamID)
        );]]) == false) then
            Sublime.Print("SQL Error: %s", sql.LastError());
        else
            Sublime.Print("Successfully created sql table: Sublime_Skills");
        end
    end

    if (not sql.TableExists("Sublime_Data")) then
        if (sql.Query([[CREATE TABLE Sublime_Data (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            ExperienceGained INTEGER,
            LevelsGained INTEGER
        );]]) == false) then
            Sublime.Print("SQL Error: %s", sql.LastError());
        else
            sql.Query("INSERT INTO Sublime_Data (ExperienceGained, LevelsGained) VALUES('0', '0')");

            Sublime.Print("Successfully created sql table: Sublime_Data");
        end
    end
end

---
--- FormatSQL
---
function SQL:FormatSQL(formatString, ...)
	local repacked 	= {};
	local args		= {...};
	
	for _, arg in ipairs(args) do 
		table.insert(repacked, sql.SQLStr(arg, true));
	end

	return string.format(formatString, unpack(repacked));
end

hook.Add("Initialize", path, function()
    SQL:CreateTables();
end);

hook.Add("PlayerInitialSpawn", path, function(ply)
    if (not IsValid(ply) or ply:IsBot()) then
        return;
    end

    local needed = math.Round(Sublime.Config.BaseExperience * Sublime.Config.ExperienceTimes);
    sql.Query(SQL:FormatSQL([[INSERT OR IGNORE INTO Sublime_Levels (SteamID, Level, Experience, TotalExperience, NeededExperience, Name) VALUES('%s', '1', '0', '0', '%i', '%s')]], ply:SteamID64(), needed, ply:Nick()));
    sql.Query(SQL:FormatSQL([[INSERT OR IGNORE INTO Sublime_Skills (SteamID, Points, Points_Spent, Skill_Data) VALUES('%s', '0', '0', '[]')]], ply:SteamID64()));

    timer.Simple(2, function()
        if (not IsValid(ply)) then
            return;
        end
        
        local levelData = sql.Query(SQL:FormatSQL("SELECT Level, Experience FROM Sublime_Levels WHERE SteamID = '%s'", ply:SteamID64()));
        local skillData = sql.Query(SQL:FormatSQL("SELECT Points, Skill_Data FROM Sublime_Skills WHERE SteamID = '%s'", ply:SteamID64()));

        local level, experience = levelData[1]["Level"], levelData[1]["Experience"];
        local points, data = skillData[1]["Points"], skillData[1]["Skill_Data"];

        local to = tonumber;
        
        ply:SetNW2Int("sl_level", to(level));
        ply:SetNW2Int("sl_experience", to(experience));
        
        ply:SL_SetInteger("experience", to(experience));
        ply:SL_SetInteger("ability_points", to(points));
        
        ---
        --- We need to have a variable for the player to see what the default run/walk speed is
        --- the DarkRP gamemode has this a variable on the gamemodes folder, however, not all gamemodes do
        --- so we have to keep track on our own.
        ---

        ply.sublime_default_walk_speed  = ply:GetWalkSpeed();
        ply.sublime_default_run_speed   = ply:GetRunSpeed();

        --- We also have to do this with the jump power.
        ply.sublime_default_jump_power  = ply:GetJumpPower();

        ---
        --- Now that the default attributes of the player has been saved, we can continue with the skills.
        --- this also makes sure, in the long run that when we buy a skill it doesn't use the modified run speed
        --- but the default one to increase.
        ---

        hook.Run("Sublime.InitializeSkills", ply, util.JSONToTable(data));

        Sublime.Print("%s is level %i with %s experience", ply:Nick(), level, string.Comma(experience));
    end);
end);

---
--- GetSQL
---
function Sublime.GetSQL()
    return SQL;
end