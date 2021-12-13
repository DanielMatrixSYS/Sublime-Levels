--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

---
--- SL_GetNeededExperience
---
--- Gets the needed experience the player needs to gain a level.
---
function Sublime.Player:SL_GetNeededExperience()
    return math.Round((self:GetNW2Int("sl_level", 1) * Sublime.Config.BaseExperience) * Sublime.Config.ExperienceTimes); 
end

---
--- GetExperience
---
function Sublime.Player:SL_GetExperience()
    return self:SL_GetInteger("experience", 0);
end