--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "The Creditor";

-- The description of the skill.
SKILL.Description       = "If you as a Traitor kill an innocent or you as a Detective kill a Traitor\nYou'll have a small chance to gain a credit.\nUp to a total of 20%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Trouble in terrorist town"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "creditor";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 2;

-- Should we enable this skill?
SKILL.Enabled           = true;

if (SERVER and SKILL.Enabled) then
    hook.Add("PlayerDeath", path, function(victim, inflictor, attacker)
        if (IsValid(victim) and IsValid(attacker) and attacker:IsPlayer()) then
            if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
                return;
            end

            local points = attacker:SL_GetInteger(SKILL.Identifier, 0) * SKILL.AmountPerPoint;

            if (points <= 0) then
                return; 
            end

            local randomNum = math.random(1, 100);

            if (attacker:IsTraitor() and not victim:IsTraitor()) then
                if (randomNum <= points) then
                    ply:SetCredits(ply:GetCredits() + 1);
    
                    Sublime.Notify(ply, "Due to your Creditor perk you've gotten an extra credit for killing an innocent!");
                end
            else
                if (attacker:IsDetective() and victim:IsTraitor()) then
                    if (randomNum <= points) then
                        ply:SetCredits(ply:GetCredits() + 1);
        
                        Sublime.Notify(ply, "Due to your Creditor perk you've gotten an extra credit for killing a traitor!");
                    end
                end
            end
        end
    end);
end
Sublime.AddSkill(SKILL);