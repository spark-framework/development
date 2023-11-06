--- @type spark
local Spark = exports['spark']

local Players, Functions = {}, {}
local Development = {} -- The development resource

--- Invoke all the callback functions
function Development:invokeFunctions()
    for _, v in pairs(Functions) do
        pcall(v)
    end
end

--- Listen to the Spark restart event
--- @param callback fun()
function Development:listen(callback)
    table.insert(Functions, callback)
end

--- When Spark gets started
--- @param name string
function Development:onResourceStart(name)
    if name ~= "spark" then -- If it isn't Spark that started
        return
    end

    self:invokeFunctions() -- Notify all the event listeners

    for steam, data in pairs(Players) do -- Loop all the current players
        if data.spawns > 0 then -- Has the player spawned atleast once
            local coords = GetEntityCoords(GetPlayerPed(data.source)) -- Save basic information
            data.data['Coords'] = {x = coords.x, y = coords.y, z = coords.z}
            data.data['Health'] = GetEntityHealth(GetPlayerPed(data.source))
        end

        print("Saved user " .. steam .. " from old players table!")
        Spark:dumpUser(steam, data.data) -- Dump the user data to the database
    end
end

--- When Spark gets closed
--- @param name string
function Development:onResourceStop(name)
    if name ~= "spark" then -- If it isn't Spark that stopped
        return
    end

    Players = Spark:getRawPlayers() -- Update the players database
end

exports('listen', function(callback)
    Development:listen(callback)
end)

AddEventHandler('onResourceStart', function(name)
    Development:onResourceStart(name)
end)

AddEventHandler('onResourceStop', function(name)
    Development:onResourceStop(name)
end)