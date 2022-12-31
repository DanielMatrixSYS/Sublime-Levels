

local path  = Sublime.GetCurrentPath();
local SKILL = {};

-- This is the name of the skill.
SKILL.Name              = "Experienced Player";

-- The description of the skill.
SKILL.Description       = "Increases the amount of experience you receive up to a total of 45%";

-- If the category of the skill does not exist then we will automatically create it.
SKILL.Category          = "Other"

-- This is the identifier in the database, needs to be unqiue.
SKILL.Identifier        = "experienced_player";

SKILL.ButtonAmount      = 15;
SKILL.AmountPerPoint    = 3;

-- Should we enable this skill?
SKILL.Enabled           = true;

Sublime.AddSkill(SKILL);