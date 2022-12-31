---
--- SL_GetAbilityPoints
---
function Sublime.Player:SL_GetAbilityPoints()
    return self:SL_GetInteger("ability_points", 0);
end

---
--- GetMaxSkill
---
function Sublime.GetMaxSkill(skill)
    for k, v in ipairs(Sublime.Skills) do
        if (v.Identifier == skill) then
            return v.ButtonAmount;
        end
    end

    return false;
end

---
--- GetSkill
---
function Sublime.GetSkill(skill)
    for k, v in ipairs(Sublime.Skills) do
        if (v.Identifier == skill) then
            return v;
        end
    end

    return false;
end

---
--- AddSkill
---
function Sublime.AddSkill(skill)
    for k, v in ipairs(Sublime.Skills) do
        if (v.Identifier == skill.Identifier) then
            return false;
        end
    end

    table.insert(Sublime.Skills, skill);
end