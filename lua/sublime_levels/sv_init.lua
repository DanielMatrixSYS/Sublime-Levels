--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

util.AddNetworkString("Sublime.Notify");

---
--- Sublime.Notify
---
function Sublime.Notify(ply, msg)
    if (Sublime.Settings.Get("other", "disable_notifications", "boolean")) then
        return false;
    end

    local prefix = Sublime.Settings.Table["SERVER"]["other"]["chat_prefix"];

    net.Start("Sublime.Notify");
        net.WriteString(prefix);
        net.WriteString(msg);
    net.Send(ply);
end