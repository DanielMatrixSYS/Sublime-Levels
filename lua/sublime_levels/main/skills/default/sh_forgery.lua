--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Forgery";

-- The description of the skill.
SKILL.Description       = "The money printed from your money printer has up to 25% chance to double";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "DarkRP"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "forgery";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 5;
SKILL.AmountPerPoint    = 5;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER and SKILL.Enabled) then
    hook.Add("moneyPrinterPrintMoney", path, function(ent, amount)
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            return;
        end

        if (ent.Getowning_ent) then
            local ply = ent:Getowning_ent();

            if (IsValid(ply)) then
                local points = ply:SL_GetInteger(SKILL.Identifier, 0);

                if (points > 0) then
                    local modifier = 1 + ((points * SKILL.AmountPerPoint) / 100);
                    amount = math.Round(amount * modifier);

                    return false, amount;
                end
            end
        end
    end);
end
Sublime.AddSkill(SKILL);