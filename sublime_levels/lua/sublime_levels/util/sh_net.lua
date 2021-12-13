--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

---
--- SL_GetInteger
---
function Sublime.Player:SL_GetInteger(identifier, default)
    return tonumber(self[identifier]) or default;
end