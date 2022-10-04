local path = Sublime.GetCurrentPath();

hook.Add("PlayerButtonUp", path, function(ply, button)
    if (ply ~= LocalPlayer() or not IsFirstTimePredicted()) then
        return;
    end

    if (button == Sublime.Settings.Get("interface", "menu_open")) then
        net.Start("Sublime.RequestInterface")
        net.SendToServer();
    end
end);