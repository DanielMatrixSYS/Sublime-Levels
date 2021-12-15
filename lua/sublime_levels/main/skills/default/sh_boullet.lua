--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "A Glitch In The Boullet";

-- The description of the skill.
SKILL.Description       = "After shooting you'll have a small chance to retrieve the ammo back into the same clip.\nUp to a total of 5%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Weapons"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "bullet";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 5;
SKILL.AmountPerPoint    = 1;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER and SKILL.Enabled) then
    hook.Add("EntityFireBullets", path, function(ent, data)
        if (IsValid(ent) and ent:IsPlayer()) then
            if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
                return;
            end

            local points = ent:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

            if (points <= 0) then
                return; 
            end

            local randomNum = math.random(1, 100);
            if (randomNum <= points) then
                local weapon = ent:GetActiveWeapon();

                if (IsValid(weapon) and weapon:Clip1() >= 0) then
                    weapon:SetClip1(weapon:Clip1() + 1);
                end
            end
        end
    end);
end
Sublime.AddSkill(SKILL);