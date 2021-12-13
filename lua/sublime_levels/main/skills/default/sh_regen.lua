--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Regeneration";

-- The description of the skill.
SKILL.Description       = "Regenerates your health when you're not in combat. Regenerates up to 2% of your max health every other second.";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Strength"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "regeneration";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 0.002;

-- Should we enable this skill?
SKILL.Enabled           = true;

-- Custom variables used by this skill only.

-- How often should the player receive health? These are in seconds.
SKILL.Cooldown = 2;

-- How long does the player need to wait before receiving health after taking damage?
SKILL.Wait = 5;

-- NOTE:
-- If you want to change how much health the player receives then you need to change the SKILL.AmountPerPoint variable.
-- The variable is extremely sensitive towards numbers, the default is 0.002. If you think this is too little then change it to 0.004;
-- The higher the variable number the more health the player will receive.

-- If you change the number then make sure to change the description to match its current number.
if (SERVER and SKILL.Enabled) then
    hook.Add("EntityTakeDamage", path, function(ent, dmg)
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            return;
        end

        if (IsValid(ent) and ent:IsPlayer()) then
            if (SKILL.Enabled and dmg:GetDamage() >= 1) then
                local points = ent:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

                if (points > 0) then
                    ent.SublimeLevels_CanRegenerate = CurTime() + SKILL.Wait;
                end
            end
        end
    end);

    -- Just the initial cooldown
    local Cooldown = CurTime() + 2;
    hook.Add("Tick", path, function()
        if (Cooldown > CurTime()) then
            return;
        end

        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            Cooldown = CurTime() + SKILL.Cooldown;
            
            return;
        end

        local players = player.GetAll();
        for i = 1, #players do
            local player = players[i];

            if (player.SublimeLevels_CanRegenerate and player.SublimeLevels_CanRegenerate <= CurTime()) then
                local maxHealth = player:GetMaxHealth();
                local points    = player:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

                if (points > 0) then
                    local health = player:Health();

                    if (health >= maxHealth) then
                        continue;
                    end

                    local newHealth = math.Clamp(health + (points * maxHealth), 1, maxHealth);
                    player:SetHealth(newHealth);
                end
            end
        end

        Cooldown = CurTime() + SKILL.Cooldown;
    end);
end

Sublime.AddSkill(SKILL);