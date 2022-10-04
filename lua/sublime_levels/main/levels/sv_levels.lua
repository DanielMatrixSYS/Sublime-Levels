local SQL = Sublime.GetSQL();
local path = Sublime.GetCurrentPath();

function Sublime.Player:SL_LevelUp(amount)
    local amount    = amount or 1;
    local new       = self:GetNW2Int("sl_level", 1) + amount;

    self:SL_SetInteger("experience", 0);
    self:SetNW2Int("sl_level", new);
    self:SetNW2Int("sl_experience", 0);
    
    Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Levels SET Level = '%s', Experience = '0', NeededExperience = '%s' WHERE SteamID = '%s'", new, self:SL_GetNeededExperience(), self:SteamID64()));
    Sublime.Query("UPDATE Sublime_Data SET LevelsGained = LevelsGained + " .. amount);

    hook.Run("SL.PlayerLeveledUp", self, new, amount)
end

function Sublime.Player:SL_SetLevel(level, give_points)
    if (not level or not isnumber(level)) then
        Sublime.Print("The argument 'level' is either nil or not a number. Its type is '%s'", type(level));

        return false;
    end

    if (level <= 0) then
        Sublime.Print("Level can not be 0 or below.");

        return false;
    end

    self:SL_SetInteger("experience", 0);
    self:SetNW2Int("sl_level", level);
    self:SetNW2Int("sl_experience", 0);

    Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Levels SET Level = '%s', Experience = '0', NeededExperience = '%s' WHERE SteamID = '%s'", level, self:SL_GetNeededExperience(), self:SteamID64()));

    -- Should the player receive ability points after we set his level?
    -- This is sometimes useful, but I would not recommend it.
    -- If you set the players level to 10 then he will receive 10 ability points regardless of his level.
    if (give_points) then
        hook.Run("SL.PlayerLeveledUp", self, level, level)
    end
end