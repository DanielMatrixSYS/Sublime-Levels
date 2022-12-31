

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "One Man Army";

-- The description of the skill.
SKILL.Description       = "Reduces damage from incoming bullets of all types up to a total of 10%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Physical"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "bullet_damage_resistance";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 1;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER and SKILL.Enabled) then
    hook.Add("EntityTakeDamage", path, function(ent, dmg)
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            return;
        end

        if (IsValid(ent) and ent:IsPlayer()) then
            if (dmg:GetDamage() > 1 and dmg:IsDamageType(DMG_BULLET)) then
                local points = ent:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

                if (points < 1) then
                    return;
                end

                local modifier = 1 - (points / 100);
                dmg:ScaleDamage(modifier);
            end
        end
    end);
end

Sublime.AddSkill(SKILL);