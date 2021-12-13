--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

---
--- Metatables
---
Sublime.Player = FindMetaTable("Player");

---
--- GetCurrentPath
---
function Sublime.GetCurrentPath()
    return debug.getinfo(2).short_src;
end

function Sublime.GetCurrentGamemode()
    return engine.ActiveGamemode()
end

---
--- Colors
---
Sublime.Colors = {};

local col               = Color;
Sublime.Colors.White    = col(255, 255, 255);
Sublime.Colors.Trans    = col(0, 0, 0, 100);
Sublime.Colors.Black    = col(0, 0, 0);
Sublime.Colors.Red      = col(200, 0, 0);
Sublime.Colors.Royal    = col(0, 150, 200);
Sublime.Colors.Green    = col(72, 219, 140, 200);
Sublime.Colors.Cyan     = col(0, 255, 191);
Sublime.Colors.Outline  = col(57, 64, 78, 225);
Sublime.Colors.Grey     = col(200, 200, 200, 200);
Sublime.Colors.Invis    = col(0, 0, 0, 0);
Sublime.Colors.Yellow   = col(200, 200, 0);
Sublime.Colors.Purple   = col(114, 0, 255);
Sublime.Colors.Orange   = col(255, 144, 0);
Sublime.Colors.Pink     = col(255, 102, 255);

---
--- Print
---
function Sublime.Print(s, ...)
    if (SERVER) then
        if (not Sublime.Settings.Get("other", "debug_enabled", "boolean")) then
            return false;
        end

        MsgC(Sublime.Colors.Red, "[Sublime");
        MsgC(Sublime.Colors.Red, "Levels");
        MsgC(Sublime.Colors.Red, "] ");
        MsgC(Sublime.Colors.White, string.format(s, ...));
        Msg("\n");
    else
        if (not Sublime.Settings.Get("other", "debug_enabled", "boolean")) then
            return false;
        end

        MsgC(Sublime.Colors.Red, "[");
        MsgC(Sublime.Colors.Black, "Sublime");
        MsgC(Sublime.Colors.Red, "Levels");
        MsgC(Sublime.Colors.Red, "] ");
        MsgC(Sublime.Colors.White, string.format(s, ...));
        Msg("\n");
    end
end