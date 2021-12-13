--[[------------------------------------------------------------------------------
 *  Copyright (C) Fluffy(76561197976769128 - STEAM_0:0:8251700) - All Rights Reserved
 *  Unauthorized copying of this file, via any medium is strictly prohibited
 *  Proprietary and confidential
--]]------------------------------------------------------------------------------

local queries   = {};
local path      = Sublime.GetCurrentPath();

---
--- Query
---
function Sublime.Query(query)
    local time = os.time();

    table.insert(queries, {
        query = query, 
        insert_time = time, 
        shouldQuery = time + 0.1 * (#queries * 0.07), 
        number = #queries + 1
    });
    
    Sublime.Print("Query #" .. #queries .. " was queued up at " .. time);
end

hook.Add("Tick", path, function()
    for i = 1, #queries do
        local data = queries[i];

        if (data) then
            local shouldQuery = data["shouldQuery"];

            if (shouldQuery <= os.time()) then
                sql.Query(data["query"]);
                Sublime.Print("Query #" .. data["number"] .. " was processed " .. os.date("%S", os.time() - data["insert_time"]) .. " after it was queued up.");
                
                table.remove(queries, i);
            end
        end
    end
end);