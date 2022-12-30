ESX.RegisterServerCallback('keyCarSysteme:ChekAutorisation', function(source, cb, plate)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT owner, statu, NameCar, optionnal FROM vehicle WHERE plate = @plate', {
        ["plate"] = plate,
    },function(resultat)
        if json.encode(resultat) ~= '[]' then
            if resultat[1].statu == 'personnel' then 
                if resultat[1].owner == xPlayer.identifier then
                    cb(true)
                else
                    cb(false)
                end
            elseif resultat[1].statu == 'crew' then
                Horizon.GetPlayerCrew(src, function(crewPlayer)
                    if resultat[1].optionnal == crewPlayer[1].crew_name then
                        Horizon.GetPlayerCrewPermission(crewPlayer[1].crew_name, crewPlayer[1].crew_grade, function(perm)
                            if perm[1].permision_car == true then
                                cb(true)
                            else
                                cb(false)
                            end
                        end)
                    else
                        cb(false)
                    end
                end)
            elseif resultat[1].statu == 'entreprise' then
                if resultat[1].optionnal == xPlayer.getJob().name then
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
