

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Ricochet";

-- The description of the skill.
SKILL.Description       = "The bullets that hit you have a chance to ricochet back to the shooter.\nUp to 20%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "General"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "ricochet";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 4;
SKILL.AmountPerPoint    = 5;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER and SKILL.Enabled) then
    hook.Add("EntityTakeDamage", path, function(target, data)
        if (IsValid(target) and target:IsPlayer()) then
            if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
                return;
            end

            local attacker = data:GetAttacker();

            if (IsValid(attacker) and attacker:IsPlayer() and data:IsDamageType(DMG_BULLET)) then
                local points = target:SL_GetInteger(SKILL.Identifier, 0);

                if (points > 0) then
                    local modifier  = points * SKILL.AmountPerPoint;
                    local random    = math.random(1, 100);

                    if (random <= modifier) then
                        local damage = data:GetDamage();

                        data:ScaleDamage(0);

                        attacker:TakeDamage(damage, attacker);

                        Sublime.Notify(target, "You ricochet " .. damage .. " damage back to " .. attacker:Nick());
                    end
                end
            end
        end
    end);
end

Sublime.AddSkill(SKILL);