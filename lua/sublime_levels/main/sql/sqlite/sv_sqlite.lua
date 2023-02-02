if (Sublime.MySQL.Enabled) then
    return;
end

local SQL   = {};
local path  = Sublime.GetCurrentPath();

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

    if (not sql.TableExists("Sublime_Levels_SkillData")) then
        if (sql.Query([[CREATE TABLE Sublime_Levels_SkillData (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            Data TEXT
        )]]) == false) then
            Sublime.Print("SQL Error: %s", sql.LastError());
        else
            sql.Query(SQL:FormatSQL("INSERT INTO Sublime_Levels_SkillData (Data) VALUES('%s')", util.TableToJSON(Sublime.Skills)));
            
            Sublime.Print("Successfully created sql table: Sublime_Levels_SkillData");
        end
    end
end

function SQL:FormatSQL(formatString, ...)
	local repacked 	= {};
	local args		= {...};
	
	for _, arg in ipairs(args) do 
		table.insert(repacked, sql.SQLStr(arg, true));
	end

	return string.format(formatString, unpack(repacked));
end

function SQL:InitializePlayerForSQLite(ply)
    local needed    = math.Round(Sublime.Config.BaseExperience * Sublime.Config.ExperienceTimes);
    local steamid   = ply:SteamID64();
    local name      = ply:Nick();

    sql.Query(SQL:FormatSQL([[INSERT OR IGNORE INTO Sublime_Levels (SteamID, Level, Experience, TotalExperience, NeededExperience, Name) VALUES('%s', '1', '0', '0', '%i', '%s')]], steamid, needed, name));
    sql.Query(SQL:FormatSQL([[INSERT OR IGNORE INTO Sublime_Skills (SteamID, Points, Points_Spent, Skill_Data) VALUES('%s', '0', '0', '[]')]], steamid));
        
    local levelData = sql.Query(SQL:FormatSQL("SELECT Level, Experience FROM Sublime_Levels WHERE SteamID = '%s'", steamid));
    local skillData = sql.Query(SQL:FormatSQL("SELECT Points, Skill_Data FROM Sublime_Skills WHERE SteamID = '%s'", steamid));

    local level, experience = levelData[1]["Level"], levelData[1]["Experience"];
    local points, data = skillData[1]["Points"], skillData[1]["Skill_Data"];

    local to = tonumber;
    
    ply:SetNW2Int("sl_level", to(level));
    ply:SetNW2Int("sl_experience", to(experience));
    
    if (DarkRP) then
        ply:setDarkRPVar("level", to(level));
    end

    ply:SL_SetInteger("experience", to(experience));
    ply:SL_SetInteger("ability_points", to(points));

    hook.Run("Sublime.InitializeSkills", ply, util.JSONToTable(data));

    Sublime.Print("%s is level %i with %s experience", name, level, string.Comma(experience));
end

hook.Add("Initialize", path, function()
    SQL:CreateTables();
end);

hook.Add("PlayerInitialSpawn", path, function(ply)
    if (not IsValid(ply) or ply:IsBot()) then
        return;
    end

    timer.Simple(2, function()
        if (IsValid(ply)) then
            SQL:InitializePlayerForSQLite(ply);
        end
    end);
end);

function Sublime.GetSQL()
    return SQL;
end