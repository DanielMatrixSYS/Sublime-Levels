util.AddNetworkString("Sublime.ExperienceNotification");

function Sublime.Player:SL_AddExperience(amount, source, notify, shouldMultiply, force)
    local amount = (amount or 50);

    if (not isnumber(tonumber(amount))) then
        Sublime.Print("Argument 'Amount' in function SL_AddExperience needs to be a number.");

        return false;
    end

    shouldMultiply = shouldMultiply == nil and true or shouldMultiply;
    
    local playersNeeded = Sublime.Settings.Get("other", "needed_on_server_before_xp", "number");
    if (player.GetCount() < playersNeeded and not force) then
        return false;
    end

    local max = Sublime.Settings.Get("other", "max_level", "number");
    if (self:SL_GetLevel() >= max) then
        return;
    end

    local sData = Sublime.GetSkill("experienced_player");
    if (sData and sData.Enabled) then
        local points = self:SL_GetInteger(sData.Identifier, 0);

        if (points > 0 and shouldMultiply) then
            local modifier = 1 + ((points * sData.AmountPerPoint) / 100);

            amount = math.Round(amount * modifier);
        end
    end

    -- VIP bonus.
    local vModifier = Sublime.Settings.Get("other", "vip_modifier", "number");
    local isVip     = Sublime.Config.VipBonus[self:GetUserGroup()];

    if (isVip and shouldMultiply) then
        amount = amount * vModifier;
    end

    local new       = self:SL_GetInteger("experience", 0) + amount;
    local needed    = self:SL_GetNeededExperience();

    if (new >= needed) then
        self:SL_LevelUp();
    else
        self:SL_SetInteger("experience", new);
        self:SetNW2Int("sl_experience", new);
    end
    
    Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET Experience = '%s' WHERE SteamID = '%s'", new, self:SteamID64()));

    if (shouldMultiply) then
        Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Levels SET TotalExperience = TotalExperience + '%s' WHERE SteamID = '%s'", amount, self:SteamID64()));
        Sublime.Query(Sublime.SQL:FormatSQL("UPDATE Sublime_Data SET ExperienceGained = ExperienceGained + '%s'", amount));
    end

    if (not source or source == "") then
        source = "from an unknown source.";
    end

    if (notify == nil) then
        notify = true;
    end

    if (notify and not Sublime.Settings.Get("other", "disable_notifications", "boolean")) then
        net.Start("Sublime.ExperienceNotification")
            net.WriteString(source);
            net.WriteUInt(amount, 32);
        net.Send(self);
    end

    local left = new - needed;
    if (left > 0) then
        self:SL_AddExperience(left, source, false, false);
    end

    hook.Run("SL.PlayerReceivedExperience", self, amount);

    return true;
end