if (not Sublime.MySQL.Enabled) then
    return;
end

require("mysqloo")

local function createSublimeLevels()
    local query = Sublime.MySQL.DB:query([[CREATE TABLE IF NOT EXISTS Sublime_Levels (
        SteamID VARCHAR(32) PRIMARY KEY NOT NULL,
        Level INT NOT NULL,
        Experience INT NOT NULL,
        TotalExperience INT NOT NULL,
        NeededExperience INT NOT NULL,
        Name VARCHAR(32) NOT NULL
    )]]);

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

    function query:onError(err)
        print(err);
    end

    query:start();
end

local function createSublimeData()
    local query = Sublime.MySQL.DB:query([[CREATE TABLE IF NOT EXISTS Sublime_Data (
        ID INT AUTO_INCREMENT PRIMARY KEY,
        ExperienceGained INT DEFAULT 0,
        LevelsGained INT DEFAULT 0
    )]]);

    function query:onError(err)
        print(err);
    end

    query:start();
end

function createSublimeSkillData()
    local query = Sublime.MySQL.DB:query([[CREATE TABLE IF NOT EXISTS Sublime_Levels_SkillData (
        ID INT AUTO_INCREMENT PRIMARY KEY,
        Data TEXT DEFAULT ('[]')
    )]]);

    function query:onError(err)
        print(err);
    end

    query:start();
end

local cred = Sublime.MySQL.Credentials;
Sublime.MySQL.DB = mysqloo.connect(cred.IPAddress, cred.Username, cred.Password, cred.Database, cred.Port);

function Sublime.MySQL.DB:onConnected()
    Sublime.Print("We have successfully connected to the MySQL database, creating the mysql tables if they don't exist.");
    
    createSublimeLevels();
    createSublimeSkills();
    createSublimeData();
    createSublimeSkillData();
end

function Sublime.MySQL.DB:onConnectionFailed(err)
    Sublime.Print("We couldn't connect to the MySQL database because of an error!");
    print(err);
end

Sublime.MySQL.DB:connect();