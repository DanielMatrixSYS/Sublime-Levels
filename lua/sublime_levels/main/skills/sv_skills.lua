--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local path  = Sublime.GetCurrentPath();
local SQL   = Sublime.GetSQL();

util.AddNetworkString("Sublime.UpgradeSkillNotify");
util.AddNetworkString("Sublime.UpgradeSkill");
util.AddNetworkString("Sublime.ResetSkills");

---
--- SL_AddSkillPoint
---
function Sublime.Player:SL_AddSkillPoint(amount)
    local amount = (amount or 1);

    if (not isnumber(tonumber(amount))) then
        Sublime.Print("Argument 'Amount' in function SL_AddSkillPoint needs to be a number.");

        return false;
    end

    local new = self:SL_GetInteger("ability_points", 0) + amount;
    self:SL_SetInteger("ability_points", new);

    Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Skills SET Points = '%s' WHERE SteamID = '%s'", new, self:SteamID64()));

    Sublime.Print("%s has now %i skill points to use.", self:Nick(), new);
    hook.Run("SL.PlayerReceivedSkillPoint", self, amount, new);
end

net.Receive("Sublime.UpgradeSkill", function(_, ply)
    if (not IsValid(ply)) then
        return;
    end

    if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
        Sublime.Print("Couldn't upgrade «%s» because skills is disabled.");
        return;
    end

    local skill     = net.ReadString();
    local steamid   = ply:SteamID64();

    if (ply:SL_GetAbilityPoints() >= 1) then
        local max = Sublime.GetMaxSkill(skill);

        if (not max or ply:SL_GetInteger(skill, 0) >= max) then
            return;
        end

        ply:SL_SetInteger(skill, ply:SL_GetInteger(skill, 0) + 1);
        ply:SL_SetInteger("ability_points", ply:SL_GetAbilityPoints() - 1);

        Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Skills SET Points = '%s' WHERE SteamID = '%s'", ply:SL_GetAbilityPoints(), steamid));

        ---
        --- Call necessary functions
        ---

        local skillTable = Sublime.GetSkill(skill);
        if (skillTable and skillTable.OnBuy) then
            skillTable.OnBuy(ply);
        end

        ---
        --- Update data
        ---

        local data = sql.Query(SQL:FormatSQL("SELECT Skill_Data FROM Sublime_Skills WHERE SteamID = '%s'", steamid));
        local tbl = util.JSONToTable(data[1]["Skill_Data"]);

        tbl[skill] = (tbl[skill] and tbl[skill] + 1) or 1;

        Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Skills SET Skill_Data = '%s' WHERE SteamID = '%s'", util.TableToJSON(tbl), steamid));
    
        net.Start("Sublime.UpgradeSkillNotify")
            net.WriteString(skillTable.Name);
            net.WriteUInt(ply:SL_GetInteger(skill, 0), 16);
            net.WriteUInt(skillTable.ButtonAmount, 16);
        net.Send(ply);
    end
end);

net.Receive("Sublime.ResetSkills", function(_, ply)
    if (not IsValid(ply) or ply:SL_GetAbilityPoints() == (ply:SL_GetLevel() - 1)) then
        return;
    end

    if (not Sublime.Settings.Get("other", "skills_enabled", "boolean")) then
        Sublime.Print("Couldn't reset «%s» because skills is disabled.");
        return;
    end

    local steamid = ply:SteamID64();

    ---
    --- Reset the skill data.
    ---
    local data  = sql.Query(SQL:FormatSQL("SELECT Skill_Data FROM Sublime_Skills WHERE SteamID = '%s'", steamid));
    local tbl   = util.JSONToTable(data[1]["Skill_Data"]) or {};

    for k, v in pairs(tbl) do
        tbl[k] = 0;
        ply:SL_SetInteger(k, 0);

        local skillTable = Sublime.GetSkill(k);
        if (skillTable and skillTable.OnBuy) then
            skillTable.OnBuy(ply);
        end
    end

    Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Skills SET Skill_Data = '%s' WHERE SteamID = '%s'", util.TableToJSON(tbl), steamid));

    ---
    --- Give back the points
    ---
    local plyShouldReceive = ply:SL_GetLevel() - 1;
    ply:SL_SetInteger("ability_points", plyShouldReceive);

    Sublime.Query(SQL:FormatSQL("UPDATE Sublime_Skills SET Points = '%s' WHERE SteamID = '%s'", plyShouldReceive, steamid));
end);

hook.Add("Sublime.InitializeSkills", path, function(ply, data)
    if (not IsValid(ply)) then
        return;
    end

    -- Set every integer in the skills table to 0 first
    for k, v in ipairs(Sublime.Skills) do
        ply:SL_SetInteger(v.Identifier, 0);
    end

    -- then set the correct values
    -- this is to ensure that if you create more skills than the default ones
    -- then it will save properly.
    for k, v in pairs(data) do
        ply:SL_SetInteger(k, v);
    end
end);