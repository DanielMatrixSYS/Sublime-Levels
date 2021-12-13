--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Break & Entry Master";

-- The description of the skill.
SKILL.Description       = "Lockpick time is reduced up to 75%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "DarkRP"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "master_thief";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 0.075;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER and SKILL.Enabled) then
    hook.Add("lockpickTime", path, function(ply, ent)
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            return;
        end
        
        local points = ply:SL_GetInteger(SKILL.Identifier, 0);

        if (points > 0) then
            local time = 30 * (1 - (points * SKILL.AmountPerPoint));

            return time;
        end
    end);
end
Sublime.AddSkill(SKILL);