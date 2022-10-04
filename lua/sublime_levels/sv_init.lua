util.AddNetworkString("Sublime.Notify");

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