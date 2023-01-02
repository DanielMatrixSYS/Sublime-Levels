if (not Sublime.MySQL.Enabled) then
    return;
end

local path = Sublime.GetCurrentPath();

Sublime.MySQL.DB = Sublime.MySQL.DB or nil;
Sublime.MySQL.ImportStarted = false;

require("mysqloo")

Sublime.MySQL.SuccessfullyCreatedTables = {};

Sublime.MySQL.SuccessfullyCreatedTables[1] = false;
Sublime.MySQL.SuccessfullyCreatedTables[2] = false;
Sublime.MySQL.SuccessfullyCreatedTables[3] = false;
Sublime.MySQL.SuccessfullyCreatedTables[4] = false;

local currentlyThinking = GetConVar("sv_hibernate_think");
Sublime.MySQL.ShouldStopThinking = false;

local function createSublimeLevels()
    local query = Sublime.MySQL.DB:query([[CREATE TABLE IF NOT EXISTS Sublime_Levels (
        SteamID VARCHAR(32) PRIMARY KEY NOT NULL,
        Level INT NOT NULL,
        Experience INT NOT NULL,
        TotalExperience INT NOT NULL,
        NeededExperience INT NOT NULL,
        Name VARCHAR(32) NOT NULL
    )]]);

    function query:onSuccess(data)
        Sublime.MySQL.SuccessfullyCreatedTables[1] = true;
    end

    function query:onError(err)
        print(err);
    end

    query:start();
end

local function createSublimeSkills()
    local query = Sublime.MySQL.DB:query([[CREATE TABLE IF NOT EXISTS Sublime_Skills (
        SteamID VARCHAR(32) PRIMARY KEY NOT NULL,
        Points INT NOT NULL,
        Points_Spent INT NOT NULL,
        Skill_Data TEXT DEFAULT ('[]')
    )]]);

    function query:onSuccess(data)
        Sublime.MySQL.SuccessfullyCreatedTables[2] = true;
    end

    function query:onError(err)
        print(err);
    end

    query:start();
end

local function createSublimeData()
    local query = Sublime.MySQL.DB:query([[CREATE TABLE IF NOT EXISTS Sublime_Data (
        ID INT AUTO_INCREMENT PRIMARY KEY,
        ExperienceGained INT DEFAULT 0,
        LevelsGained INT DEFAULT 1
    )]]);

    function query:onSuccess(data)
        Sublime.MySQL.SuccessfullyCreatedTables[3] = true;
    end

    function query:onError(err)
        print(err);
    end

    query:start();
end

local function createSublimeSkillData()
    local query = Sublime.MySQL.DB:query([[CREATE TABLE IF NOT EXISTS Sublime_Levels_SkillData (
        ID INT AUTO_INCREMENT PRIMARY KEY,
        Data TEXT DEFAULT ('[]')
    )]]);

    function query:onSuccess(data)
        Sublime.MySQL.SuccessfullyCreatedTables[4] = true;
    end

    function query:onError(err)
        print(err);
    end

    query:start();
end

function Sublime.MySQL:InitializeTables()
    createSublimeLevels();
    createSublimeSkills();
    createSublimeData();
    createSublimeSkillData();
end

hook.Add("Initialize", path, function()
    if (currentlyThinking:GetInt() == 0) then
        RunConsoleCommand("sv_hibernate_think", "1");

        Sublime.MySQL.ShouldStopThinking = true;
    end
end);

hook.Add("Tick", path, function()
    local foundFalse = false;

    for i = 1, #Sublime.MySQL.SuccessfullyCreatedTables do
        local data = Sublime.MySQL.SuccessfullyCreatedTables[i];

        if (not data) then
            foundFalse = true;
            break;
        end
    end

    if (not foundFalse) then
        hook.Run("Sublime.MySQL.Initialize")

        hook.Remove("Tick", path);
    end
end);

local cred = Sublime.MySQL.Credentials;
Sublime.MySQL.DB = mysqloo.connect(cred.IPAddress, cred.Username, cred.Password, cred.Database, cred.Port);

function Sublime.MySQL.DB:onConnected()
    Sublime.Print("We have successfully connected to the MySQL database, creating the mysql tables if they don't exist.");

    Sublime.MySQL:InitializeTables();
end

function Sublime.MySQL.DB:onConnectionFailed(err)
    Sublime.Print("We couldn't connect to the MySQL database because of an error!");
    print(err);
end

Sublime.MySQL.DB:connect();