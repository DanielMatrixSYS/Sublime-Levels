--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Killology";

-- The description of the skill.
SKILL.Description       = "Increases the damage output of your weapons. An increase up to a total of 5%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Weapons"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "damage_increase";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 0.005;

-- Should we enable this skill?
SKILL.Enabled           = true;

-- Should the weapons list below be a Whitelist or a blacklist?
-- Only one can be enabled at a time.
SKILL.Whitelist = false;
SKILL.Blacklist = false;

-- Should the weapon damage increase only work for players?
-- If you set this to false then it will be everything that can take damage such as,
-- Props, NPC's, Players and Entities in general.
SKILL.PlayerOnly = true;

-- If 'Whitelist' is set to true then the weapons below are the only weapons that will increase in damage, every other will stay the same.
-- If 'Blacklist' is set to true then the weapons below won't increase in damage, but every other will.
SKILL.List = {
    ["weapon_357"] = true,
};

if (SERVER) then
    hook.Add("EntityTakeDamage", path, function(ent, dmg)
        if (IsValid(ent) and SKILL.Enabled) then
            if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
                return;
            end
            
            local damage = dmg:GetDamage();

            if (damage < 1) then
                return;
            end

            local attacker = dmg:GetAttacker();
            if (not IsValid(attacker) or not attacker:IsPlayer()) then
                return;
            end

            local points = attacker:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;
            if (points <= 0) then
                return; 
            end

            local weapon = attacker.GetActiveWeapon and attacker:GetActiveWeapon();

            if (IsValid(weapon)) then
                local class = weapon:GetClass();

                if (class) then
                    if (SKILL.Whitelist and not SKILL.List[class]) then
                        return;
                    end

                    if (SKILL.Blacklist and SKILL.List[class]) then
                        return;
                    end

                    local realDamage = damage + (points * damage);
                    if (SKILL.PlayerOnly) then
                        if (ent:IsPlayer()) then
                            dmg:SetDamage(realDamage);
                        end
                    else
                        dmg:SetDamage(realDamage);
                    end
                end
            end
        end
    end);
end

Sublime.AddSkill(SKILL);