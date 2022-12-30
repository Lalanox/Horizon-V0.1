ESX.RegisterServerCallback('utilscar:GetPlayerCar', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT NameCar, plate, statu FROM vehicle WHERE owner = @player', {
        ["player"] = xPlayer.identifier,
    },function(resultat)
        cb(resultat)
    end)

end)

RegisterNetEvent('utilscar:ChangeStatuCar')
AddEventHandler('utilscar:ChangeStatuCar', function(action, plate)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)

    if action == 'Perso'then
        MySQL.Async.execute('UPDATE vehicle SET statu = @statu, optionnal = @optionnal WHERE plate = @plate ', {
            ['@statu'] = 'personnel',
            ["@optionnal"] = NULL,
            ["@plate"] = plate,
        })
        xPlayer.showNotification("~r~Gestion véhicule\n~s~Vous venez de passer votre véhicule : ~b~"..plate.."~s~ en ~g~Personnel", true, true)
    elseif action == 'Crw' then
        Horizon.GetPlayerCrew(src, function(resultat)
            if json.encode(resultat) =='[[]]' then
                local xPlayer = ESX.GetPlayerFromId(src)
                xPlayer.showNotification("~r~Gestion véhicule\n~s~Action ~r~impossible~s~ vous n'avez pas de crew", true, true)
            else
                MySQL.Async.execute('UPDATE vehicle SET statu = @statu, optionnal = @optionnal WHERE plate = @plate ', {
                    ['@statu'] = 'crew',
                    ["@optionnal"] = resultat[1].crew_name,
                    ["@plate"] = plate,
                })
                xPlayer.showNotification("~r~Gestion véhicule\n~s~Vous venez de passer votre véhicule : ~b~"..plate.."~s~ au crew ~g~"..resultat[1].crew_name, true, true)
            end
        end)
    elseif action == 'Entrp' then
        print(json.encode(xPlayer.getJob()))
        if xPlayer.getJob().name ~= 'unemployed' then
            MySQL.Async.execute('UPDATE vehicle SET statu = @statu, optionnal = @optionnal WHERE plate = @plate ', {
                ['@statu'] = 'entreprise',
                ["@optionnal"] = xPlayer.getJob().name,
                ["@plate"] = plate,
            })
            xPlayer.showNotification("~r~Gestion véhicule\n~s~Votre véhicule : ~b~"..plate.."~s~ est passer à l'entreprise ~g~"..xPlayer.getJob().label, true, true)
        else
            xPlayer.showNotification("~r~Gestion véhicule\n~s~Vous n'avez pas de travail", true, true)
        end
    end
end)