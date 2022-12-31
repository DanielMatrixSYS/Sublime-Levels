

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "The Duplicator";

-- The description of the skill.
SKILL.Description       = "After buying a piece of equipment you'll have a chance to not consume the credit.\nUp to a total of 20%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Trouble in terrorist town"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "duplicator";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 2;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER and SKILL.Enabled) then
    hook.Add("TTTOrderedEquipment", path, function(ply)
        if (IsValid(ply)) then
            if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
                return;
            end

            local points = ply:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

            if (points <= 0) then
                return; 
            end

            local randomNum = math.random(1, 100);
            if (randomNum <= points) then
                ply:SetCredits(ply:GetCredits() + 1);

                Sublime.Notify(ply, "Due to your Duplicator perk you've gotten back the credit you just spent!");
            end
        end
    end);
end
Sublime.AddSkill(SKILL);