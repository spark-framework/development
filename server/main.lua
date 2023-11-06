--- @type spark
local Spark = exports['spark']

local Players, Functions = {}, {}
local Development = {}

function Development:invoke()
    for _, v in pairs(Functions) do
        pcall(v)
    end
end

--- @param name string
function Development:onResourceStart(name)
    if name ~= "spark" then -- If it isn't Spark that started
        return
    end

    self:invoke()

    for steam, data in pairs(Players) do -- Loop all old users
        if data.spawns > 0 then
            local coords = GetEntityCoords(GetPlayerPed(data.source))
            data.data['Coords'] = {x = coords.x, y = coords.y, z = coords.z}
            data.data['Health'] = GetEntityHealth(GetPlayerPed(data.source))
        end

        print("Saved user " .. steam .. " from old players table!")
        Spark:dumpUser(steam, data.data) -- Dump the user data to the database
    end
end

--- @param name string
function Development:onResourceStop(name)
    if name ~= "spark" then -- If it isn't Spark that stopped
        return
    end

    Players = exports['spark']:getRawPlayers()
end

--- @param callback fun()
function Development:listen(callback)
    table.insert(Functions, callback)
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