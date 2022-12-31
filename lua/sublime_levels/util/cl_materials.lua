Sublime.Materials = Sublime.Materials or {};

local mat       = Material;
local path      = "sublime_levels/";
local current   = Sublime.GetCurrentPath();
local materials = {
    {
        name = "SL_Background",
        material = mat(path .. "main_background.png", "noclamp smooth")
    },

    {
        name = "SL_X",
        material = mat(path .. "x.png", "noclamp smooth")
    },

    {
        name = "SL_Settings",
        material = mat(path .. "settings.png", "noclamp smooth")
    },

    {
        name = "SL_User",
        material = mat(path .. "user.png", "noclamp smooth")
    },

    {
        name = "SL_Home",
        material = mat(path .. "home.png", "noclamp smooth")
    },

    {
        name = "SL_AdminSettings",
        material = mat(path .. "settings.png", "noclamp smooth")
    },

    {
        name = "SL_Leaderboards",
        material = mat(path .. "rankings.png", "noclamp smooth")
    },

    {
        name = "SL_Upgrade",
        material = mat(path .. "upgrade.png", "noclamp smooth")
    },

    {
        name = "SL_LeftArrow",
        material = mat(path .. "left_arrow.png", "noclamp smooth")
    },

    {
        name = "SL_ServerSettings",
        material = mat(path .. "server-settings.png", "noclamp smooth")
    },

    {
        name = "SL_Checked",
        material = mat(path .. "save.png", "noclamp smooth")
    },

    {
        name = "SL_Header",
        material = mat(path .. "header.png", "noclamp smooth")
    },

    {
        name = "SL_Cross",
        material = mat(path .. "refresh.png", "noclamp smooth")
    },

    {
        name = "SL_Locked",
        material = mat(path .. "lock_locked.png", "noclamp smooth")
    },

    {
        name = "SL_Unlocked",
        material = mat(path .. "lock_unlocked.png", "noclamp smooth")
    },

    {
        name = "SL_Acquired",
        material = mat(path .. "acquired.png", "noclamp smooth")
    },

    {
        name = "SL_World",
        material = mat(path .. "world.png", "noclamp smooth")
    },

    {
        name = "SL_Help",
        material = mat(path .. "help.png", "noclamp smooth")
    },

    {
        name = "SL_Rank_1",
        material = mat(path .. "rank_1.png", "noclamp smooth")
    }
};

for _, v in ipairs(materials) do
    Sublime.Materials[v.name] = v.material;
end