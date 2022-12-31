util.AddNetworkString("Sublime.NetworkData");

local NET_TYPE_INTEGER  = 0x1;
local NET_TYPE_STRING   = 0x2;
local NET_TYPE_BOOLEAN  = 0x3;

---
--- sendNetworkedData
---
--- Helper function for the meta functions below
---
local function sendNetworkedData(ply, net_type, identifier, value)
    ply[identifier] = value;

    net.Start("Sublime.NetworkData");
        net.WriteUInt(net_type, 4);
        net.WriteString(identifier);

        if (net_type == NET_TYPE_INTEGER) then
            net.WriteUInt(value, 32);
        elseif(net_type == NET_TYPE_STRING) then
            net.WriteString(value);
        else
            net.WriteBool(value);
        end
    net.Send(ply);
end

---
--- SL_SetInteger
---
function Sublime.Player:SL_SetInteger(identifier, int)
    if (not IsValid(self)) then
        return false;
    end

    if (not identifier or identifier == "") then
        Sublime.Print("Argument 'identifier' in SL_SetInteger can not be empty.");

        return false;   
    end

    if (not isnumber(tonumber(int))) then
        Sublime.Print("Argument 'int' in SL_SetInteger needs to be a integer, use SL_SetString or SL_SetBoolean for anything else.");

        return false;    
    end

    sendNetworkedData(self, NET_TYPE_INTEGER, identifier, int);
end

---
--- SL_SetString
---
function Sublime.Player:SL_SetString(identifier, str)
    if (not IsValid(self)) then
        return false;
    end

    if (not identifier or identifier == "") then
        Sublime.Print("Argument 'identifier' in SL_SetString can not be empty.");

        return false;   
    end

    if (not str or str == "") then
        Sublime.Print("Argument 'str' in SL_SetString needs to be a string, use SL_SetInteger or SL_SetBoolean for anything else.");

        return false;    
    end

    sendNetworkedData(self, NET_TYPE_STRING, identifier, str);
end

---
--- SL_SetBoolean
---
function Sublime.Player:SL_SetBoolean(identifier, bool)
    if (not IsValid(self)) then
        return false;
    end

    if (not identifier or identifier == "") then
        Sublime.Print("Argument 'identifier' in SL_SetBoolean can not be empty.");

        return false;   
    end

    if (not isbool(tobool(bool))) then
        Sublime.Print("Argument 'bool' in SL_SetBoolean needs to be a boolean, use SL_SetInteger or SL_SetString for anything else.");

        return false;    
    end

    sendNetworkedData(self, NET_TYPE_BOOLEAN, identifier, bool);
end