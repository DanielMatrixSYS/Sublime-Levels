--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

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