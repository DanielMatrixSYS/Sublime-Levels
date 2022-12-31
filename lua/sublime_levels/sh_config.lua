Sublime.Config = Sublime.Config or {};

---
--- 
--- EXPERIENCE
---
--- You can mess around with these settings but if the numbers are either to low or too high then
--- you might create imbalance in gaining levels/experience.

--- The base experience the player needs to get to level 2.
--- This is used for a numerous amount of things,
--- such as, calculating how much experience they need to gain a level, etc.
--- Changing this after players have received levels won't change the players levels.
--- But it will affect their next levels, and newcomers will be affected, too.
Sublime.Config.BaseExperience = 1000;

---
--- This is how much we should times the XP by
---
--- This is how much XP the players would have to get in order to reach level 11.
--- The equation would be:
--- (player_level * BaseExperience) * ExperienceTimes;
--- (10 * 1000) * 1.57 = 15,700;
---
--- Changing the ExperienceTimes variable below will significantly change the difficulty of gaining levels.
--- Say if you changed it to 0.5;
--- It would be:
--- (10 * 1000) * 0.5 = 5,000;
---
--- However, if you doubled it(3)
--- It would be:
--- (10 * 1000) * 3 = 30,000;
--- 
Sublime.Config.ExperienceTimes = math.pi / 2;

---
--- This is for Tommy's SpecDM
--- Should we allow players to gain experience even though they're in SpecDM?
---
Sublime.Config.SpecExperience = false;

---
--- 
--- ACCESS
---

--- Who has access to the config in-game?
Sublime.Config.ConfigAccess = {
    ["superadmin"] = true
};

Sublime.Config.VipBonus = {
    ["superadmin"] = true,
    ["admin"] = true,
    ["vip"] = true,
    ["vip+"] = true,
}