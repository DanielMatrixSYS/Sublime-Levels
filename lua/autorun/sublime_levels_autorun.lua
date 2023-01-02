if (Sublime and not Sublime.IsAuthentic) then
    error("Global table 'Sublime' is already in use by another addon, we're not continuing.")
end

Sublime = Sublime or {};
Sublime.Languages   = Sublime.Languages or {};
Sublime.Skills      = Sublime.Skills or {};
Sublime.IsAuthentic = true;

function Sublime:LoadFile(path)
    local filename = path:GetFileFromFilename();
    filename = filename ~= "" and filename or path;

    local flagCL    = filename:StartWith("cl_");
    local flagSV    = filename:StartWith("sv_");
    local flagSH    = filename:StartWith("sh_");

    if (SERVER) then
        if (flagCL or flagSH) then
            AddCSLuaFile(path);
        end

        if (flagSV or flagSH) then 
            include(path);
        end
    elseif (flagCL or flagSH) then
        include(path);
    end
end

function Sublime:LoadDirectory(dir)
    local files, folders = file.Find(dir .. "/*", "LUA");

    for _, v in ipairs(files) do 
        self:LoadFile(dir .. "/" .. v);
    end

    for _, v in ipairs(folders) do 
        self:LoadDirectory(dir .. "/" .. v);
    end
end

Sublime:LoadDirectory("sublime_levels");