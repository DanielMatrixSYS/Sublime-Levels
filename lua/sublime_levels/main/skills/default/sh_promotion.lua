

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Promotion";

-- The description of the skill.
SKILL.Description       = "Your salay increases up to a total of 25% more";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "DarkRP"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "promotion";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 5;
SKILL.AmountPerPoint    = 5;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER and SKILL.Enabled) then
    hook.Add("playerGetSalary", path, function(ply, amount)
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            return;
        end
        
        local points = ply:SL_GetInteger(SKILL.Identifier, 0);

        if (points > 0) then
            local modifier = 1 + ((points * SKILL.AmountPerPoint) / 100);
            
            amount = math.Round(amount * modifier);

            return false, DarkRP.getPhrase("payday_message", DarkRP.formatMoney(amount)), amount;
        end
    end);
end

Sublime.AddSkill(SKILL);