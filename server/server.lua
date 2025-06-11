RSGCore = exports['rsg-core']:GetCoreObject()
lib.locale()

lib.callback.register('rkt:balloon:server:requestData', function(source)
    local xPlayer = RSGCore.Functions.GetPlayer(source)
    if not xPlayer then return nil end

    local citizenid = xPlayer.PlayerData.citizenid
    local result = MySQL.Sync.fetchAll("SELECT * FROM rkt_ballon WHERE ownerID = ?", {citizenid})

    if result and #result > 0 then
        return result[1]
    end
    
    return nil
end)


lib.callback.register('rkt:balloon:server:fuelBalloon', function(source)
    return true
end)

RegisterNetEvent('rkt:balloon:server:updateStatus', function(index)
    local xPlayer = RSGCore.Functions.GetPlayer(source)
    if not xPlayer then return nil end
    local citizenid = xPlayer.PlayerData.citizenid

    MySQL.Sync.execute("UPDATE rkt_ballon SET outside = ? WHERE ownerID = ?", {
        index,
        citizenid
    })
end)

lib.callback.register('rkt:balloon:server:BuyPayment' , function(source,days)
    local xPlayer = RSGCore.Functions.GetPlayer(source)
    local payAmount = Config.BalloonPrice
    if not xPlayer then return nil end

    local citizenid = xPlayer.PlayerData.citizenid

    if xPlayer.Functions.RemoveMoney('cash', payAmount) then
        local randomLetters = string.char(math.random(65, 90), math.random(65, 90), math.random(65, 90))
        local ballonID = randomLetters .. math.random(100, 999)
        local time = 0

        if days then
            time = days * 24 * 60 * 60
        end

        exports.oxmysql:execute('INSERT INTO `rkt_ballon` (ownerID, ballonID, outside, fuel, status, rentalTime) VALUES (?, ?, ?, ?, ?, ?)', {citizenid, ballonID, 0, 100, 100, time})
        return true
    end
    return false
end)

lib.callback.register('rkt:balloon:server:BuyBalloon' , function(source,days)
    local xPlayer = RSGCore.Functions.GetPlayer(source)
    if not xPlayer then return nil end

    local citizenid = xPlayer.PlayerData.citizenid
    local result = MySQL.Sync.fetchAll("SELECT * FROM rkt_ballon WHERE ownerID = ?", {citizenid})

    if next(result) then return true end 

    return false
end)

function giveBallon(source, days)
    local xPlayer = RSGCore.Functions.GetPlayer(source)
    if not xPlayer then
        return
    end
    local citizenid = xPlayer.PlayerData.citizenid
    local randomLetters = string.char(math.random(65, 90), math.random(65, 90), math.random(65, 90))
    local ballonID = randomLetters .. math.random(100, 999)
    local time = 0
    if days then
        time = days * 24 * 60 * 60
    end
    exports.oxmysql:execute('INSERT INTO `rkt_ballon` (ownerID, ballonID, outside, fuel, status, rentalTime) VALUES (?, ?, ?, ?, ?, ?)', {
        citizenid, ballonID, 0, 100, 100, time
    }, function(id)
        return id
    end)
end

function removeBallon(source)
    local xPlayer = RSGCore.Functions.GetPlayer(source)
    if not xPlayer then
        return
    end
    local citizenid = xPlayer.PlayerData.citizenid
    MySQL.query.await("DELETE FROM rkt_ballon WHERE ownerID = ?", {citizenid})
end


RSGCore.Commands.Add("giveballoon", '', {}, false, function(source, args)
    local src = source
    local targetId = args[1]
    giveBallon(targetId)
end, 'admin')


RSGCore.Commands.Add("removeballoon", '', {}, false, function(source, args)
    local src = source
    local targetId = args[1]
    removeBallon(targetId)
end, 'admin')