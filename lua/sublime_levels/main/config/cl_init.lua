local path = Sublime.GetCurrentPath();

hook.Add("Sublime.PlayerChangedSettings", path, function(category, setting, value)
    Sublime.Settings.Set(category, setting, value);
    Sublime.Settings.Save();
end);

net.Receive("Sublime.SyncServerWithClients", function(_, ply)
    Sublime.Settings.Table["SERVER"] = net.ReadTable();

    hook.Run("Sublime.SettingsRefreshed");
end);