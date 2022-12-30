ESX.RegisterServerCallback('trunk:GetLimitkCar', function(source, cb, plate)
    MySQL.Async.fetchAll('SELECT  spawnNameCar FROM vehicle WHERE plate = @plate', {
        ["plate"] = plate,
    },function(resultat)
        print(json.encode(resultat))
        if json.encode(Limit) ~= '[]' then
            MySQL.Async.fetchAll('SELECT  inventory FROM vehicle WHERE plate = @plate', {
                ["plate"] = plate,
            },function(otherResult)
                local allItems = {}
                -- print(json.decode(otherResult[1].inventory))
                for k,v in pairs(json.decode(otherResult[1].inventory)) do
                    print("ici c'est le k " ,k)
                   
                    allItems[k] = {
                        name = k,
                        quant = v
                    }
                end
                cb(otherResult, resultat)
            end)
        else
            cb(resultat, false)
        end
    end)
end)

RegisterNetEvent('trunk:AddNewItem')
AddEventHandler('trunk:AddNewItem', function(item, count, plate)

    local itemToAdd = {}
    itemToAdd = {
        name = item,
        quant = count,
    }

    print(json.encode(itemToAdd))
    MySQL.Async.execute('UPDATE vehicle SET inventory = @item WHERE plate = @plate ', {
        ['@item'] = json.encode(itemToAdd),
        ["@plate"] = plate,
    })

end)