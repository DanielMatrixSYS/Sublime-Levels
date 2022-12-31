if (not Sublime.MySQL.Enabled) then
    return;
end

Sublime.MySQL.Credentials = {};

---
--- MySQL IPAddress
---
Sublime.MySQL.Credentials.IPAddress = "127.0.0.1";

---
--- MySQL Username
---
Sublime.MySQL.Credentials.Username  = "root";

---
--- MySQL Password
---
Sublime.MySQL.Credentials.Password  = "root";

---
--- MySQL Database
---
Sublime.MySQL.Credentials.Database  = "sublime_levels";

---
--- MySQL Port
---
Sublime.MySQL.Credentials.Port      = "3306";