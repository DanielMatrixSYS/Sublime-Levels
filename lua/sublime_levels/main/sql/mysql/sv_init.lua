local SQL = {};
local path = Sublime.GetCurrentPath();

function SQL:InsertPlayer(ply)
    local needed    = math.Round(Sublime.Config.BaseExperience * Sublime.Config.ExperienceTimes);
    local steamid   = ply:SteamID64();
    local name      = ply:Nick();

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
    prep:setNumber(2, 1);
    prep:setNumber(3, 0);
    prep:setNumber(4, 0);
    prep:setNumber(5, needed);
    prep:setString(6, name);

    prep:start();
end

function SQL:InsertPlayerSkills(ply)
    local prep = Sublime.MySQL.DB:prepare("INSERT IGNORE INTO Sublime_Skills (SteamID, Points, Points_Spent, Skill_Data) VALUES(?, ?, ?, ?)");

    function prep:onSuccess(data)
        if (prep:affectedRows() > 0) then
            Sublime.Print("Successfully inserted rows into [InsertPlayerSkills]");
        end
    end

    function prep:onError(err)
        print("MySQL error in [InsertPlayerSkills]: " .. err);
    end

    prep:setString(1, ply:SteamID64());
    prep:setNumber(2, 0);
    prep:setNumber(3, 0);
    prep:setString(4, '[]');

    prep:start();
end

function SQL:Query(query, callback)
    local statement = query[1];
    local lookup = query[2];

    local prep = Sublime.MySQL.DB:prepare(statement);

    function prep:onSuccess(data)
        callback(data);
    end

    function prep:onError(err)
        print("Error in [Select] on query [" .. query .. "]: " .. err);
    end

    if (isstring(lookup)) then
        prep:setString(1, lookup);
    elseif (isnumber(lookup)) then
        prep:setNumber(1, lookup);
    elseif (isbool(lookup)) then
        prep:setBoolean(1, lookup);
    else
        prep:setNull(1, lookup);
    end

    prep:start();
end

function SQL:InitializePlayerFromMySQL(ply)
    self:InsertPlayer(ply);
    self:InsertPlayerSkills(ply);

    local steamid = ply:SteamID64();
    local to = tonumber;

    self:Query({"SELECT Level, Experience FROM Sublime_Levels Where SteamID = ?", steamid}, function(data)
        ply:SetNW2Int("sl_level", to(data[1].Level));
        ply:SetNW2Int("sl_experience", to(data[1].Experience));

        ply:SL_SetInteger("experience", to(data[1].Experience));

        Sublime.Print("%s is level %i with %s experience", ply:Nick(), data[1].Level, string.Comma(data[1].Experience));
    end);
    
    self:Query({"SELECT Points, Skill_Data FROM Sublime_Skills WHERE SteamID = ?", steamid}, function(data)
        ply:SL_SetInteger("ability_points", to(data[1].Points));


        hook.Run("Sublime.InitializeSkills", ply, util.JSONToTable(data[1].Skill_Data)); 
    end);
end

hook.Add("PlayerInitialSpawn", path, function(ply)
    if (not IsValid(ply) or ply:IsBot()) then
        return;
    end

    timer.Simple(2, function()
        if (IsValid(ply)) then
            SQL:InitializePlayerFromMySQL(ply);
        end
    end);
end);

function SQL:FormatSQL(formatString, ...)
	local repacked 	= {};
	local args		= {...};
	
	for _, arg in ipairs(args) do 
		table.insert(repacked, Sublime.MySQL.DB:escape(arg));
	end

	return string.format(formatString, unpack(repacked));
end

function Sublime.GetSQL()
    return SQL;
end