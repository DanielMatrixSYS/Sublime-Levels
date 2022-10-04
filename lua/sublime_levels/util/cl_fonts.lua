Sublime.Fonts = {};

local prefix = "Sublime.";

local function fontExists(font)
    for k, v in ipairs(Sublime.Fonts) do
        if (v.font == font) then
            return true;
        end
    end

    return false;
end

local function removeFont(font)
    for k, v in ipairs(Sublime.Fonts) do
        if (v.font == font) then
            table.remove(Sublime.Fonts, k)
            break;
        end
    end

    return true;
end

local function createFont(name, size, weight)
    table.insert(Sublime.Fonts, {font = name, size = size});
    surface.CreateFont(name, {font = "Nunito", size = size, weight = (weight or 400)});
end

local function addFont(name, size, weight)
    if (fontExists(name)) then
        removeFont(name);
        createFont(name, size, weight);
    else
        createFont(name, size, weight);
    end

    return true;
end

for i = 12, 48, 2 do
    addFont(prefix .. i, i);
end