--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

if (not Sublime.MySQL.Enabled) then
    return;
end

Sublime.MySQL.Credentials = {};

---
--- MySQL IPAddress
---
Sublime.MySQL.Credentials.IPAddress = "localhost";

---
--- MySQL Username
---
Sublime.MySQL.Credentials.Username  = "root";

---
--- MySQL Password
---
Sublime.MySQL.Credentials.Password  = "!yungler123!";

---
--- MySQL Database
---
Sublime.MySQL.Credentials.Database  = "sublime_levels_database";

---
--- MySQL Port
---
Sublime.MySQL.Credentials.Port      = "3306";