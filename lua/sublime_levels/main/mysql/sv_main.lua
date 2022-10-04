if (not Sublime.MySQL.Enabled) then
    return;
end

require("mysqloo")

local cred = Sublime.MySQL.Credentials;
Sublime.MySQL.DB = mysqloo.connect(cred.IPAddress, cred.Username, cred.Password, cred.Database, cred.Port);

function Sublime.MySQL.DB:onConnected()
    Sublime.Print("We have successfully connected to the MySQL database");

    local q = self:query("CREATE DATABASE IF NOT EXISTS " .. cred.Database);
    function q:onSuccess()
        local sublime_levels = Sublime.MySQL.DB:query([[CREATE TABLE IF NOT EXISTS Sublime_Levels (
            ID INTEGER AUTO_INCREMENT PRIMARY KEY,
            SteamID VARCHAR(17) NOT NULL,
            Level INTEGER NOT NULL,
            Experience INTEGER NOT NULL,
            TotalExperience INTEGER NOT NULL,
            NeededExperience INTEGER NOT NULL,
            Name VARCHAR(32) NOT NULL,
            UNIQUE KEY unique_steamid (SteamID)
        )]]);

        function sublime_levels:onSuccess()
            Sublime.Print("Successfully created table, sublime_levels for database sublime_levels_database");
        end

        function sublime_levels:onError(err)
            Sublime.Print("An error has occured: " .. err);
        end

        sublime_levels:start();
    end

    function q:onError()
        print("no");
    end

    q:start();
end

function Sublime.MySQL.DB:onConnectionFailed(err)
    Sublime.Print("We couldn't connect to the MySQL database because of an error!");
    Sublime.Print("The error is: " .. err);
end

Sublime.MySQL.DB:connect();