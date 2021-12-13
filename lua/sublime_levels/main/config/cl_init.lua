--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path = Sublime.GetCurrentPath();

hook.Add("Sublime.PlayerChangedSettings", path, function(category, setting, value)
    Sublime.Settings.Set(category, setting, value);
    Sublime.Settings.Save();
end);

net.Receive("Sublime.SyncServerWithClients", function(_, ply)
    Sublime.Settings.Table["SERVER"] = net.ReadTable();

    hook.Run("Sublime.SettingsRefreshed");
end);