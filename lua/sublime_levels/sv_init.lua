util.AddNetworkString("Sublime.Notify");

Sublime.SQL = nil;

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

hook.Add("Tick", Sublime.GetCurrentPath(), function()
    if (not Sublime.SQL and Sublime.GetSQL) then
        Sublime.SQL = Sublime.GetSQL();

        hook.Remove("Tick", Sublime.GetCurrentPath());
    end
end);