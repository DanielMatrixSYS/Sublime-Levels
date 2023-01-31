local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "You better call Saul";

-- The description of the skill.
SKILL.Description       = "Reduces the amount of time you are in jail for. up to total of 25% reduction in jail time. (2.5% time reduction per point)";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "DarkRP";

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "you_better_call_saul";

-- The amount of buttons on the skill page.
SKILL.ButtonAmount      = 10;
SKILL.AmountPerPoint    = 2.5;

-- Should we enable this skill?
SKILL.Enabled           = true;

-- Keep track of the players that are arrested.
SKILL.Arrested          = SKILL.Arrested or {};

if (SERVER and SKILL.Enabled) then
    hook.Add("playerArrested", path, function(criminal, time, actor)
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            return;
        end

        local points = criminal:SL_GetInteger(SKILL.Identifier, 0);

        if (points > 0) then
            local before = time;
            local toReduce = (points * SKILL.AmountPerPoint) / 100;
            time = time - (time * toReduce);
            
            SKILL.Arrested[criminal] = CurTime() + time;
        end
    end);

    hook.Add("playerUnArrested", path, function(criminal)
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            return;
        end

        if (SKILL.Arrested[criminal]) then
            SKILL.Arrested[criminal] = nil;
        end
    end);

    hook.Add("Tick", path, function()
        if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
            hook.Remove("Tick", path)

            return;
        end

        local players = player.GetAll();

        for i = #players, 1, -1 do
            local ply = players[i];

            if (SKILL.Arrested[ply] and SKILL.Arrested[ply] < CurTime()) then
                ply:unArrest();
            end
        end
    end);
end
Sublime.AddSkill(SKILL);