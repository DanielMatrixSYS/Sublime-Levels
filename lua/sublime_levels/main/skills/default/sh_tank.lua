--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Tank";

-- The description of the skill.
SKILL.Description       = "Reduces incoming damage from NPC's by 50%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Strength"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "npc_damage_resistance";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 5;
SKILL.AmountPerPoint    = 10;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER) then
    hook.Add("EntityTakeDamage", path, function(ent, dmg)
        if (IsValid(ent) and ent:IsPlayer()) then
            if (SKILL.Enabled and dmg:GetDamage() > 1) then
                local attacker = dmg:GetAttacker();

                if (attacker:IsNPC()) then
                    local points = ent:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

                    if (points < 1) then
                        return;
                    end

                    local modifier = 1 - (points / 100);
                    dmg:ScaleDamage(modifier);
                end
            end
        end
    end);
end

Sublime.AddSkill(SKILL);