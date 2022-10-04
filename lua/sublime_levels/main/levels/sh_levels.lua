function Sublime.Player:SL_GetLevel()
    return self:GetNW2Int("sl_level", 1);
end