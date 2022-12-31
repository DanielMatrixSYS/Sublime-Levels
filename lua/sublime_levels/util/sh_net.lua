---
--- SL_GetInteger
---
function Sublime.Player:SL_GetInteger(identifier, default)
    return tonumber(self[identifier]) or default;
end