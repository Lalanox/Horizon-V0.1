Horizon.RemoveMoneyFromCurrentAccount = function(player, price, cb)
    local xPlayer = ESX.GetPlayerFromId(player)

    MySQL.Async.fetchAll('SELECT solde FROM banque WHERE player = @player AND actuel = @actuel', {
        ["player"] = xPlayer.identifier,
        ["actuel"] = 1,
    },function(resultat)
            if tonumber(resultat[1].solde) >= tonumber(price) then
                local newSolde = tonumber(resultat[1].solde) - tonumber(price)
                MySQL.Async.execute('UPDATE banque SET solde = @newSolde WHERE player = @player AND actuel = @actuel ', {
                    ['@newSolde'] = newSolde,
                    ["@player"] = xPlayer.identifier,
                    ["@actuel"] = 1,
                })
                cb(true)
            else
                cb(false)
            end
    end)
end

Horizon.GetPlayerCrew = function(player, cb)
    local xPlayer = ESX.GetPlayerFromId(player)
    MySQL.Async.fetchAll('SELECT crew_name, crew_grade FROM users WHERE identifier = @player ', {
        ["player"] = xPlayer.identifier,
    },function(resultat)
        cb(resultat)
    end)
end

Horizon.GetPlayerCrewPermission = function(crew, grade, cb)
    MySQL.Async.fetchAll('SELECT permission_gestion, permision_bank, permision_car FROM crew WHERE name = @crew AND grade = @grade ', {
        ["crew"] = crew,
        ["grade"] = grade,
    },function(resultat)
        cb(resultat)
    end)
end