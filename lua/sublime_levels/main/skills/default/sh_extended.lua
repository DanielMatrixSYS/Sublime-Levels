local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "X-tended Magazine";

-- The description of the skill.
SKILL.Description       = "Increases the clipsize of your primary ammunition up to a total of 25%. (2.5% increase per point)";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Weapons";

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "extended_magazine";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 2.5;

-- Should we enable this skill?
-- Under development, do not use this.
SKILL.Enabled           = false;

-- Keep track of the players that are arrested.
SKILL.Arrested          = SKILL.Arrested or {};

if (SKILL.Enabled) then
    hook.Add("PlayerSwitchWeapon", path, function(ply, old, new)
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            return;
        end

        if (not IsValid(new) or not IsValid(ply) or new.sublime_has_altered_clip) then
            print("hehe")
            return;
        end

        local points = ply:SL_GetInteger(SKILL.Identifier, 0);

        if (points > 0) then
            local clip  = new:Clip1();
            local max   = new:GetMaxClip1();

            if (max > 0) then
                local amount = math.Round(max * (SKILL.AmountPerPoint / 100) * points);

                if (new.Primary and new.Primary.ClipSize) then
                    new.Primary.ClipSize = max + amount;
                    new:SetClip1(clip + amount);

                    new.sublime_has_altered_clip = true;
                    new.sublime_clip_size = new.Primary.ClipSize;
                else
                    print("no")
                end
            end
        end
    end);
end
Sublime.AddSkill(SKILL);