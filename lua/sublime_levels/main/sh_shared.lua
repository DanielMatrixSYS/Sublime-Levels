SUBLIME_GIVE_LEVELS   = 0x1;
SUBLIME_TAKE_LEVELS   = 0x2;
SUBLIME_GIVE_SKILLS   = 0x3;
SUBLIME_TAKE_SKILLS   = 0x4;
SUBLIME_GIVE_XP       = 0x5;
SUBLIME_RESET_XP      = 0x6;
SUBLIME_RESET_USER    = 0x7;
SUBLIME_DELETE_USER   = 0x8;

if (DarkRP) then
    DarkRP.registerDarkRPVar("level", net.WriteDouble, net.ReadDouble);
end
