local balloon
local lockZ = false
local group = "balloon_controls"
local currenBalloon = 0

lib.locale()

function CreateVeh(model, spawn, data)
    local head = GetEntityHeading(playerPed)
    local hash = GetHashKey('hotAirBalloon01')

    while not HasModelLoaded(hash) do
        Wait(10)
        RequestModel(hash)
    end

    if DoesEntityExist(balloon) then
        SetEntityAsMissionEntity(balloon)
        DeleteEntity(balloon)
        balloon = nil
    end

    local balloon = CreateVehicle(hash, spawn.x, spawn.y-2.0, spawn.z, head, true, true)
    currenBalloon = balloon
    TriggerServerEvent('rkt:balloon:server:updateStatus', 1)
end

local function opeUI(k, v)
    exports.ox_target:addBoxZone({
        coords = vector3(v.npc.x, v.npc.y, v.npc.z),
        options = {
            {
            label = locale("Buy_Baloon"),
            icon = "",
            debug = true,
            onSelect = function()
                local input = lib.inputDialog(locale("Buy_Baloon"), {
                {type = 'checkbox', label = locale("buy_confirmation"), required = true},})

                if input then
                    local hasBalloon = lib.callback.await('rkt:balloon:server:BuyBalloon', false,30)

                    if hasBalloon then
                         lib.notify({
                            title = locale("Balloon"),
                            description = locale("owned_balloon"),
                        })
                       return
                    end
                    local hasMoney = lib.callback.await('rkt:balloon:server:BuyPayment',source,30)
                    
                    if hasMoney then
                        lib.notify({
                            title = locale("Balloon"),
                            description = locale("balloon_bought"),
                        })
                    end
                end
            end,
            },
            {
            label = "Pegar Balão",
            icon = "",
            debug = true,
            onSelect = function()
                local locations = {}
                local data = lib.callback.await('rkt:balloon:server:requestData', false)

                if not data then
                    lib.notify({
                        title = locale('Balloon'),
                        description = locale('not_owned'),
                        type = 'error',
                        duration = 5000
                    })
                    return
                end
                locations = {{ id = k, combustivel = data.fuel, desgaste = data.status, isOut = data.outside}}
                SendNUIMessage({
                    action = "openUI",
                    locations = locations
                })

                SetNuiFocus(true, true)
            end,
        },
        }
    })
end


RegisterNUICallback("close-callback", function(data, cb)
    SetNuiFocus(false, false) 
end)

RegisterNUICallback("outVeh-callback", function(data, cb)
    -- local spawn = Config.Spawn
    local spawn = Config.locations[tonumber(data.id)].spawn
    local isPosOccupied = IsPositionOccupied(spawn.x, spawn.y, spawn.z, 10, false, true, true, false, false, 0, false)

    if isPosOccupied then return end
    CreateVeh('hotAirBalloon01', spawn)
    isOut = true
end)

RegisterNUICallback("storeVeh-callback", function(data, cb)
    local npcCoords = Config.locations[tonumber(data.id)].npc
    local targetCoords = GetEntityCoords(currenBalloon) -- Pegando a posição correta do veículo
    local v3 = vector3(npcCoords.x,npcCoords.y,npcCoords.z)
    local distance = #(v3 - targetCoords) -- Calculando a distância corretamente
    
    if distance <= 30 then
        DeleteVehicle(currenBalloon)
        currenBalloon = nil
        isOut = false
        TriggerServerEvent('rkt:balloon:server:updateStatus', 0)
    end
end)


Citizen.CreateThread(function()
    while true do
        local vehicle = GetVehiclePedIsUsing(PlayerPedId())
        local isBalloon = GetEntityModel(vehicle) == 'hotairballoon01'

        if not balloon and isBalloon then
            balloon = vehicle
        elseif balloon and not isBalloon then
            balloon = nil
        end

        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    local bv

    while true do
        if balloon then
            jo.prompt.displayGroup(group, locale('Balloon_Controls'))

            local speed = jo.prompt.isPressed("INPUT_VEH_TRAVERSAL") and 0.15 or 0.05
            local v1 = GetEntityVelocity(balloon)
            local v2 = v1

            if jo.prompt.isPressed("INPUT_VEH_MOVE_UP_ONLY") then
                v2 = v2 + vector3(0, speed, 0)
            end

            if jo.prompt.isPressed("INPUT_VEH_MOVE_DOWN_ONLY") then
                v2 = v2 - vector3(0, speed, 0)
            end

            if jo.prompt.isPressed("INPUT_VEH_MOVE_LEFT_ONLY") then
                v2 = v2 - vector3(speed, 0, 0)
            end

            if jo.prompt.isPressed("INPUT_VEH_MOVE_RIGHT_ONLY") then
                v2 = v2 + vector3(speed, 0, 0)
            end

            if jo.prompt.isPressed("INPUT_VEH_BRAKE") then
                if bv then
                    local x = bv.x > 0 and bv.x - speed or bv.x + speed
                    local y = bv.y > 0 and bv.y - speed or bv.y + speed
                    v2 = vector3(x, y, v2.z)
                end
                bv = v2.xy
            else
                bv = nil
            end

            if jo.prompt.isCompleted(group, "INPUT_VEH_SHUFFLE") then
                lockZ = not lockZ
                local newLabel = lockZ and locale('Altitude_unlock')
                jo.prompt.editKeyLabel(group, "INPUT_VEH_SHUFFLE", newLabel)
            end

            if lockZ and not jo.prompt.isPressed("INPUT_VEH_FLY_THROTTLE_UP") then
                SetEntityVelocity(balloon, vector3(v2.x, v2.y, 0.0))
            elseif v2 ~= v1 then
                SetEntityVelocity(balloon, v2)
            end

            Citizen.Wait(0)
        else
            Citizen.Wait(500)
        end
    end
end)

local peds = {}

local function createPeds(v)
    local modelHash = GetHashKey("cs_mollyoshea")

    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do
        Wait(10)
    end

    local currentPed = CreatePed(modelHash, v.npc.x, v.npc.y, v.npc.z-1, v.npc.w, true, true, true, true)
    FreezeEntityPosition(currentPed, true)
    SetEntityInvincible(currentPed, true)
    SetBlockingOfNonTemporaryEvents(currentPed, true)
    SetRandomOutfitVariation(currentPed, true)
    SetModelAsNoLongerNeeded(modelHash)

    table.insert(peds, currentPed)
end

CreateThread(function()
    while not LocalPlayer.state.isLoggedIn do
        Wait(1000)
    end

    for k, v in pairs(Config.locations) do
        Wait(2000)
        opeUI(k, v)
        createPeds(v)
    end
end)


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        for i = 1, #peds do
            if DoesEntityExist(peds[i]) then
                DeletePed(peds[i])
            end
        end
    end
end)

