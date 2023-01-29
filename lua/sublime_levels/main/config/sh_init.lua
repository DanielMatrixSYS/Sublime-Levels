local path = Sublime.GetCurrentPath();

Sublime.MySQL = Sublime.MySQL or {};

--Enable to activate MySQL.
--In order for this to work properly, you have to manually create a database called: sublime_levels
--All of the associated tables will be created as soon as the server is started.
Sublime.MySQL.Enabled = false;

Sublime.Settings = Sublime.Settings or {};
Sublime.Settings.Table = Sublime.Settings.Table or {
    ["SERVER"] = {
        ["kills"] = {
            ["player_on_kill_experience"]   = 150,
            ["headshot_modifier"]           = 1.2,
            ["npc_on_kill_experience"]      = 100,
        },
        
        ["other"] = {
            ["vip_modifier"]                = 2,
            ["max_level"]                   = 99,
            ["xp_for_playing_when"]         = 600,
            ["xp_for_playing"]              = 25,
            ["needed_on_server_before_xp"]  = 0,
            ["skills_enabled"]              = true,
            ["should_broadcast_levelup"]    = true,
            ["chat_command"]                = "slevels",
            ["sound_on_level"]              = "",
            ["sound_on_xp"]                 = "",
            ["chat_prefix"]                 = "[Sublime Levels]",
            ["disable_notifications"]       = false,
            ["debug_enabled"]               = false,
        },

        ["darkrp"] = {
            ["lottery_winner"]      = 2000,
            ["hitman_completed"]    = 300,
            ["player_arrested"]     = 75,
            ["player_taxed"]        = 25,
            ["tax_cooldown"]        = 20,
        },

        ["ttt"] = {
            ["killing_traitors"]    = 200,
            ["killing_innocent"]    = 50,
            ["killing_detective"]   = 200,  
            ["traitor_winners"]     = 200,
            ["innocent_winners"]    = 200,
            ["draw"]                = 50,
            ["should_innocent_get_xp_when_dead"]        = false,
            ["should_traitor_get_xp_when_dead"]         = true,
            ["should_spectators_get_xp_when_roundend"]  = false,
        },

        ["murder"] = {
            ["murderer_winners"]    = 500,
            ["bystander_winners"]   = 250,
        }
    },

    --- Default client settings the client will save when first connecting.
    ["CLIENT"] = {
        ["hud"] = {
            ["display"]     = true,
            ["hud_x"]       = 0,
            ["hud_y"]       = 0,
            ["hud_bar"]     = false,
            ["hud_circle"]  = false,
            ["hud_modern"]  = true,
        },

        ["interface"] = {
            ["menu_open"]   = KEY_F6,
            ["blur"]        = true,
        },

        ["other"] = {
            ["debug_enabled"] = false,
            ["experience_notifications"] = true,
        }
    }
};

local realm = SERVER and "SERVER" or "CLIENT";

---
--- settingsExist
---
local function settingsExist(category, setting)
    if (not Sublime.Settings.Table[realm][category]) then
        Sublime.Print("The category '%s' does not exist in the settings table.", tostring(category));

        return false;
    end

    if (Sublime.Settings.Table[realm][category][setting] == nil) then
        Sublime.Print("The setting '%s' does not exist in the settings table.", tostring(setting));

        return false;
    end

    return true;
end

---
--- Get
---
function Sublime.Settings.Get(category, setting, settings_type)
    if (not settingsExist(category, setting)) then
        return false;
    end

    local retrieved_setting = Sublime.Settings.Table[realm][category][setting];
    
    if (settings_type == "string") then
        return tostring(retrieved_setting);
    elseif(settings_type == "number") then
        return tonumber(retrieved_setting);
    elseif(settings_type == "boolean") then
        return tobool(retrieved_setting);
    else
        return retrieved_setting;
    end
end

----
--- Set
---
function Sublime.Settings.Set(category, setting, value)
    if (not settingsExist(category, setting)) then
        return false;
    end

    Sublime.Settings.Table[realm][category][setting] = value;
    Sublime.Settings.Save();
end

---
--- Save
---
function Sublime.Settings.Save()
    file.Write("sublime_levels_settings.txt", util.TableToJSON(Sublime.Settings.Table[realm]));

    if (not file.Exists("sublime_levels_settings_default.txt", "DATA")) then
        file.Write("sublime_levels_settings_default.txt", util.TableToJSON(Sublime.Settings.Table[realm]));
    end

    Sublime.Print("Saved custom Sublime Levels settings to /data/sublime_levels_settings.txt");
end

---
--- Load
---
function Sublime.Settings.Load()
    local data = util.JSONToTable(file.Read("sublime_levels_settings.txt", "DATA"));

    for category, categoryValues in pairs(data) do
        for name, value in pairs(categoryValues) do
            Sublime.Settings.Table[realm][category][name] = value;
        end
    end

    Sublime.Print("Settings for Sublime Levels has been loaded on the " .. realm:lower() .. ".");
end

---
--- Sync
---
--- This is to sync the serverside settings with the administrators
--- that have access to this side of the config.
---
function Sublime.Settings.Sync(caller)
    if (IsValid(caller)) then
        net.Start("Sublime.SyncServerWithClients");
            net.WriteTable(Sublime.Settings.Table["SERVER"]);
        net.Send(caller);

        return true;
    end

    local pCount    = player.GetCount();
    local pPlayers  = player.GetAll();
    local sCount    = 0;

    for i = 1, pCount do
        local ply = pPlayers[i];

        if (IsValid(ply)) then
            net.Start("Sublime.SyncServerWithClients");
                net.WriteTable(Sublime.Settings.Table["SERVER"]);
            net.Send(ply);

            sCount = sCount + 1;
        end
    end

    Sublime.Print("Synced server side settings with " .. sCount .. " client" .. Either(sCount == 1, "", "s") .. ".");
end

---
--- IsMissingData
---
--- Checks for missing data betweeen the default settings and the current settngs n shid
---
function Sublime.Settings.IsMissingData()
    local default   = util.JSONToTable(file.Read("sublime_levels_settings_default.txt", "DATA"));
    local saved     = util.JSONToTable(file.Read("sublime_levels_settings.txt", "DATA"));
    local current   = table.Copy(Sublime.Settings.Table[realm]);
    local missing   = 0;

    -- If the category in the text file does not have the categories in the table above then
    -- we need to create it before we continue.
    for c_category, c_data in pairs(current) do
        if (not saved[c_category]) then
            saved[c_category] = {};

            missing = missing + 1;
        end
    end

    for c_category, c_data in pairs(current) do
        for k, v in pairs(c_data) do
            if (saved[c_category][k] == nil) then
                saved[c_category][k] = v;

                missing = missing + 1;
            end
        end
    end 

    if (missing >= 1) then
        file.Write("sublime_levels_settings_default.txt", util.TableToJSON(Sublime.Settings.Table[realm]));
        file.Write("sublime_levels_settings.txt", util.TableToJSON(saved));

        Sublime.Print("Found " .. missing .. " setting in the current settings table that does not exist in the default settings table.");
        Sublime.Print("Inserted the missing data into the default settings table without interfering with the editted values.");
    else
        Sublime.Print("Our current table matches with the default settings.");
    end
end

---
--- Reset
---
function Sublime.Settings.Reset()
    file.Write("sublime_levels_settings.txt", file.Read("sublime_levels_settings_default.txt", "DATA"));

    Sublime.Settings.Load();

    if (SERVER) then
        Sublime.Settings.Sync();
    end

    Sublime.Print("Sublime Levels's settings have been reset to their default values on the " .. realm);
end

hook.Add("InitPostEntity", path, function()
    if (file.Exists("sublime_levels_settings.txt", "DATA")) then
        Sublime.Settings.Load();
        Sublime.Settings.IsMissingData();
    else
        if (CLIENT) then
            Sublime.Settings.Set("hud", "hud_x", ScrW() - 100);
            Sublime.Settings.Set("hud", "hud_y", 80);
        end

        Sublime.Settings.Save();
    end
end);