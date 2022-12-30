RegisterNetEvent('concess:BuyCar')
AddEventHandler('concess:BuyCar', function(nameCar, price, spawnName)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local plate = string.upper(Horizon.GetRandomLetter(3) .. ' ' ..Horizon.GetRandomNumber(4))
    Horizon.RemoveMoneyFromCurrentAccount(src, price, function(resultat)
        if resultat == true then
            MySQL.Async.fetchAll('SELECT * FROM vehicle WHERE plate = @plate', {
                ["plate"] = plate,
            },function(resultat)
                if json.encode(resultat) == '[]' then
                    MySQL.Async.insert('INSERT INTO vehicle ( owner, plate, spawnNameCar, NameCar, statu, park) VALUES (@owner, @plate, @spawnNameCar, @NameCar, @statu, @park);', {
                        ["@owner"] = xPlayer.identifier,
                        ["@plate"] = plate,
                        ["@spawnNameCar"] = spawnName,
                        ["@NameCar"] = nameCar,
                        ["@statu"] = 'personnel',
                        ["@park"] = 0,
                    })
                    TriggerClientEvent('concess:GiveCar', src, plate, spawnName,nameCar)
                    TriggerClientEvent('banque:NotifPayement', src, "Achat de véhicule", price)
                end
                while json.encode(resultat) == '[]' do
                    Wait(0)
                    plate = string.upper(Horizon.GetRandomLetter(3) .. ' ' ..Horizon.GetRandomNumber(4))
                end
            end)
        else
            xPlayer.showNotification("~r~Concessionnaire\n~s~Vous n'avez pas assez d'argent sur votre ~b~compte courant", true, true)
        end
    end)

end)