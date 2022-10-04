function Sublime.Player:SL_GetNeededExperience()
    return math.Round((self:GetNW2Int("sl_level", 1) * Sublime.Config.BaseExperience) * Sublime.Config.ExperienceTimes); 
end

function Sublime.Player:SL_GetExperience()
    return self:SL_GetInteger("experience", 0);
end