local queries   = {};
local path      = Sublime.GetCurrentPath();

function Sublime.Query(query)
    local time = os.time();

    table.insert(queries, {
        query = query, 
        insert_time = time, 
        shouldQuery = time + 0.1 * (#queries * 0.07), 
        number = #queries + 1
    });
    
    Sublime.Print("Query #" .. #queries .. " was queued up at " .. os.date("%H:%M:%S", time));
end

hook.Add("Tick", path, function()
    for i = 1, #queries do
        local data = queries[i];
        local timeNow = os.time();

        if (data) then
            local shouldQuery = data["shouldQuery"];

            if (shouldQuery <= timeNow) then
                if (Sublime.MySQL.Enabled) then
                    local query = Sublime.MySQL.DB:query(data["query"]);

                    function query:onSuccess()
                        if (query:affectedRows() > 0) then
                            Sublime.Print("Query #" .. data["number"] .. " was processed " .. string.NiceTime(timeNow - data["insert_time"]) .. " after it was queued up.");
                        end
                    end

                    function query:onError(err)
                        print("Error on query[" .. data["query"] .. "]: " .. err);
                    end

                    query:start();
                else
                    sql.Query(data["query"]);
                    Sublime.Print("Query #" .. data["number"] .. " was processed " .. os.date("%S", timeNow - data["insert_time"]) .. " after it was queued up.");
                end

                table.remove(queries, i);
            end
        end
    end
end);