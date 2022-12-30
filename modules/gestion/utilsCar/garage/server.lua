ESX.RegisterServerCallback("garage:GetOwnerVehicle", function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT plate, spawnNameCar, NameCar, park, custom FROM vehicle WHERE owner = @player AND statu = @statu', {
        ["player"] = xPlayer.identifier,
        ["statu"] = 'personnel',
    },function(resultat)
        cb(resultat)
    end)
end)

ESX.RegisterServerCallback("garage:GetSocietyVehicle", function(src, cb, job)

    MySQL.Async.fetchAll('SELECT plate, spawnNameCar, NameCar, park, custom FROM vehicle WHERE statu = @statu AND optionnal = @optionnal', {
        ["statu"] = 'entreprise',
        ["optionnal"] = job,
    },function(resultat)
        cb(resultat)
    end)

end)

ESX.RegisterServerCallback("garage:ChekIfPossible", function(src, cb, plate)
    MySQL.Async.fetchAll('SELECT park FROM vehicle WHERE plate = @plate', {
        ["plate"] = plate,
    },function(resultat)
        if resultat[1].park == true then
            cb(true)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('garage:GetSharedVehicle', function(source, cb)
    Horizon.GetPlayerCrew(source, function(resultat)
        Horizon.GetPlayerCrewPermission(resultat[1].crew_name, resultat[1].crew_grade, function(other)
            if other[1].permision_car == true then
                MySQL.Async.fetchAll('SELECT plate, spawnNameCar, NameCar, park, custom FROM vehicle WHERE statu = @statu AND optionnal = @crew', {
                    ["crew"] = resultat[1].crew_name,
                    ["statu"] = 'crew',
                },function(last)
                    cb(last)
                end)
            else
                cb(false)
            end
        end) 
    end)
end)


ESX.RegisterServerCallback('garage:StoreCar', function(source, cb, plate, custom)
    local xPlayer = ESX.GetPlayerFromId(source)
    MySQL.Async.fetchAll('SELECT  owner, statu, optionnal FROM vehicle WHERE plate = @plate', {
        ["plate"] = plate,
    },function(resultat)
        if json.encode(resultat) ~= '[]' then
            if resultat[1].statu == 'personnel' then
                if xPlayer.identifier == resultat[1].owner then
                    MySQL.Async.execute('UPDATE vehicle SET park = @park, custom = @custom WHERE plate = @plate ', {
                        ['@park'] = 1,
                        ['@custom'] = json.encode(custom),
                        ["@plate"] = plate,
                    })
                    cb(true)
                else
                    cb(false)
                end
            elseif resultat[1].statu == 'crew' then
                Horizon.GetPlayerCrew(source, function(crewPlayer)
                    if crewPlayer[1].crew_name == resultat[1].optionnal then
                        MySQL.Async.execute('UPDATE vehicle SET park = @park, custom = @custom WHERE plate = @plate ', {
                            ['@park'] = 1,
                            ['@custom'] = json.encode(custom),
                            ["@plate"] = plate,
                        })
                        cb(true)
                    else
                        cb(false)
                    end
                end)
            elseif resultat[1].statu == 'entreprise' then
                if xPlayer.getJob().name == resultat[1].optionnal then
                    MySQL.Async.execute('UPDATE vehicle SET park = @park, custom = @custom WHERE plate = @plate ', {
                        ['@park'] = 1,
                        ['@custom'] = json.encode(custom),
                        ["@plate"] = plate,
                    })
                    cb(true)
                else
                    cb(false)
                end
            end
        else
            cb(false)
        end
    end)
end)

RegisterNetEvent('garage:SetVehicleStatu')
AddEventHandler('garage:SetVehicleStatu', function(plate)
    MySQL.Async.execute('UPDATE vehicle SET park = @park WHERE plate = @plate ', {
        ['@park'] = 0,
        ["@plate"] = plate,
    })
end)

