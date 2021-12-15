--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Double Luck";

-- The description of the skill.
SKILL.Description       = "After you have won the lottery you'll have another chance to win half of what you originally won.\nUp to 50%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "DarkRP"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "double_luck";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 5;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER and SKILL.Enabled) then
    hook.Add("lotteryEnded", path, function(_, ply, amount)
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            return;
        end

        if (not IsValid(ply)) then
            return;
        end
        
        local points = ply:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

        if (points > 0) then
            local after = amount / 2;
            local rand  = math.random(0, 100);

            if (points <= rand) then
                ply:addMoney(after);

                DarkRP.notify(ply, 1, 5, "You have won an extra " .. DarkRP.formatMoney(after) .. " due to your Double Luck perk.");
            end
        end
    end);
end
Sublime.AddSkill(SKILL);