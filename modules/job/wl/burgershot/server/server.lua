local function len(table)
    local index = 0
    for k,v in pairs(table) do
        index = index + 1;
    end
    return index;
end

local function checkPosition(sourcePlayer, otherSource, distance)
    local dst = #(GetEntityCoords(GetPlayerPed(sourcePlayer)) - GetEntityCoords(GetPlayerPed(otherSource)))
    if dst < distance then return true; end
    return false;
end

RegisterServerEvent("burgershot:AddItems")
AddEventHandler("burgershot:AddItems", function(countItems, nameItems)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.removeInventoryItem(nameItems, countItems)

    MySQL.Async.fetchAll('SELECT * FROM addon_inventory_items WHERE name = @itemName AND inventory_name = @burgershot', {
        ["burgershot"] = "society_burgershot",
        ["@itemName"] = nameItems
    },function(resultat)
        if (json.encode(resultat)) == '[]' then
            MySQL.Async.insert('INSERT INTO addon_inventory_items ( inventory_name, name, count) VALUES (@burgershot, @itemName, @count);', {
                ["@burgershot"] = "society_burgershot",
                ["@itemName"] = nameItems,
                ["@count"] = countItems,
            })
        else
            for k,v in pairs(resultat) do
                MySQL.Async.fetchAll('UPDATE addon_inventory_items SET count = @count WHERE name = @name ', {
                    ['@count'] = v.count + countItems,
                    ["@name"] = nameItems,
                })
            end
        end
    end)
end)


RegisterServerEvent("burgershot:DeleteItems")
AddEventHandler("burgershot:DeleteItems", function (countItemsSelect, NameItemSelect)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.addInventoryItem(NameItemSelect, countItemsSelect)
    MySQL.Async.fetchAll('SELECT * FROM addon_inventory_items WHERE name = @itemName AND inventory_name = @burgershot', {
        ["burgershot"] = "society_burgershot",
        ["@itemName"] = NameItemSelect
    },function(resultat)
            MySQL.Async.fetchAll('UPDATE addon_inventory_items SET count = @count WHERE name = @name ', {
                ['@count'] = tonumber(resultat[1]['count'])-countItemsSelect,
                ["@name"] = NameItemSelect,
            })
    end)
end)

RegisterServerEvent("burgershot:updateJob")
AddEventHandler("burgershot:updateJob", function (type, closestPlayer)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if not closestPlayer then
        print("[BurgerShot] Tentative de cheat de la part de " ..GetPlayerName(src).. "no (closestPlayer)");
        return;
    end

    local TargetPlayer =  ESX.GetPlayerFromId(closestPlayer);
    local JobTarget = TargetPlayer.getJob();
    print(json.encode(JobTarget))

    local position = checkPosition(xPlayer.source, TargetPlayer.source, 10.0);
    if not position then
        print("[BurgerShot] Tentative de cheat de la part de " ..GetPlayerName(src).. " hors de portée");
        return;
    end
    
    if type == "add" then
        if JobTarget.name == 'burgershot' then
            if JobTarget.grade == 0 then
                TargetPlayer.setJob('burgershot', 1);
                xPlayer.showNotification('~r~Burgershot~w~\nVous venez de promouvoir la personne ~g~Manager', true, true);
                TargetPlayer.showNotification('~r~Burgershot~w~\nVous venez d\'être promu ~g~Manager', true, true);
            elseif JobTarget.grade == 1 then
                TargetPlayer.setJob('burgershot', 2);
                xPlayer.showNotification('~r~Burgershot~w~\nAttention vous venez de promouvoir la personne ~g~Patron', true, true);
                TargetPlayer.showNotification('~r~Burgershot~w~\nVous venez d\'être promu ~g~Patron', true, true);
            elseif JobTarget.grade == 2 then
                xPlayer.showNotification('~r~Burgershot~w~\nVous ne pouvez pas augmenter le grade plus haut que ~g~Patron', true, true);
            end
        else 
            TargetPlayer.setJob('burgershot', 0);
            xPlayer.showNotification('~r~Burgershot~w~\nVous venez de recruter la personne ', true, true)
            TargetPlayer.showNotification('~r~Burgershot~w~\nVous avez été recruté dans l\'entreprise Burgershot', true, true);
        end
    elseif type == "rmv" then
        if JobTarget.name == 'burgershot' then
            if JobTarget.grade == 2 then
                TargetPlayer.setJob('burgershot', 1);
                xPlayer.showNotification('~r~Burgershot~w~\nVous avez ~r~destituer~s~ la personne ~g~Manager', true, true)
                TargetPlayer.showNotification('~r~Burgershot~w~\nVous avez éte ~r~destituer~s~ au rang de ~b~Manager', true, true)
            elseif JobTarget.grade == 1 then
                TargetPlayer.setJob('burgershot', 0);
                xPlayer.showNotification('~r~Burgershot~w~\nVous avez ~r~destituer~s~ la personne au rang ~g~Equipier', true, true)
                TargetPlayer.showNotification('~r~Burgershot~w~\nVous avez éte ~r~destituer~s~ au rang de ~b~Equipier', true, true)
            elseif JobTarget.grade == 0 then
                TargetPlayer.setJob('unemployed', 0);
                xPlayer.showNotification('~r~Burgershot~w~\nVous avez virer la ~r~personne', true, true)
                TargetPlayer.showNotification('~r~Burgershot~w~\nVous avez été ~r~virer', true, true)
            end
        end
    end
end)

RegisterServerEvent('burgershot:shopItems')
AddEventHandler('burgershot:shopItems', function(nameShopItem, Price, quantity)
    local src = source;
    local xPlayer = ESX.GetPlayerFromId(src);
    local totalPrice = Price*quantity;
    local MoneyOfPlayer =xPlayer.getMoney();

    if MoneyOfPlayer >= totalPrice then 
        xPlayer.removeMoney(totalPrice)
        xPlayer.addInventoryItem(nameShopItem, quantity)
    else
        xPlayer.showNotification('~r~Burgershot~w~\nVous n\'avez pas assez d\'argent', true, true)
    end

end)

RegisterServerEvent('burgershot:addMoneyInSociety')
AddEventHandler('burgershot:addMoneyInSociety', function(MoneyToRemove)
    local src = source;
    local xPlayer = ESX.GetPlayerFromId(src);
    local MoneyAccountPlayer = xPlayer.getAccounts();

    if tonumber(MoneyAccountPlayer[3].money) <= tonumber(MoneyToRemove) then
        xPlayer.showNotification('~r~Burgershot~w~\nVous n\'avez pas assez d\'argent sur votre compte courant', true, true)
    else
        MySQL.Async.fetchAll('SELECT money FROM addon_account_data WHERE account_name = @burgershot', {
            ["burgershot"] = "society_burgershot"
        },function(resultat)
            if resultat[1] then
                local newBalanceSociety = resultat[1]['money'] + MoneyToRemove
                MySQL.Async.fetchAll('UPDATE addon_account_data SET money = @money WHERE account_name = @name ', {
                    ['@money'] = newBalanceSociety,
                    ["@name"] = 'society_burgershot'
                })
                xPlayer.removeAccountMoney('bank', tonumber(MoneyToRemove))
                xPlayer.showNotification('~r~Burgershot~w~\nVous avez fait un virement de ~g~'..MoneyToRemove..'$', true, true)
            else
                print("aucun résultat! (burgershot:addMoneyInSociety)")
            end
        end)
    end
end)

RegisterServerEvent('burgershot:removeMoneyInSociety')
AddEventHandler('burgershot:removeMoneyInSociety', function(MoneyToRemove)
    local src = source;
    local xPlayer = ESX.GetPlayerFromId(src);
    local MoneyAccountPlayer = xPlayer.getAccounts();
    
    MySQL.Async.fetchAll('SELECT money FROM addon_account_data WHERE account_name = @burgershot', {
        ["burgershot"] = "society_burgershot",
    },function(resultat)
        if (resultat[1]) then
            if tonumber(MoneyToRemove) > tonumber(resultat[1]['money']) then
                xPlayer.showNotification('~r~Burgershot~w~\nVous n\'avez pas assez d\'argent sur votre compte société', true, true)
            else
                local newRemoveBalanceSociety = resultat[1]['money'] - MoneyToRemove;
                MySQL.Async.fetchAll('UPDATE addon_account_data SET money = @money WHERE account_name = @name ', {
                    ['@money'] = newRemoveBalanceSociety,
                    ["@name"] = 'society_burgershot',
                })
                xPlayer.addAccountMoney('bank', tonumber(MoneyToRemove))
                xPlayer.showNotification('~r~Burgershot~w~\nVous avez reçu un virement de~g~ '..MoneyToRemove..'$', true, true)
            end
        else
            print("aucun résultat trouvé dans SELECT money FROM addon_account_data WHERE account_name = @burgershot")
        end
    end)
    
end)


ESX.RegisterServerCallback("SendNecessarieItems", function(src, cb, NecessariItems)
    local good = len(NecessariItems)
    local xPlayer = ESX.GetPlayerFromId(src)
    local NameBurger = nil
    local NombreAvoir = 0
    for k,v in pairs(NecessariItems) do
        if k == xPlayer.getInventoryItem(k).name and xPlayer.getInventoryItem(k).count >= v.quantiti then
            NombreAvoir = NombreAvoir +1
        end
    end
    if NombreAvoir == good then
        for k,v in pairs(NecessariItems) do
            xPlayer.removeInventoryItem(k, v.quantiti)
            NameBurger = v.name
        end
        xPlayer.addInventoryItem(NameBurger, 1)
        cb(true)
    else
        cb(false)
    end
end)


ESX.RegisterServerCallback("GetInventoryJob", function(src, cb)
    MySQL.Async.fetchAll('SELECT * FROM addon_inventory_items WHERE  inventory_name = @burgershot', {
        ["burgershot"] = "society_burgershot",
    },function(resultat)
        cb(resultat)
    end)
end)

ESX.RegisterServerCallback("burgershot:GetMoneyInSociety", function(src, cb)
    MySQL.Async.fetchAll('SELECT money FROM addon_account_data WHERE account_name = @burgershot', {
        ["burgershot"] = "society_burgershot",
    },function(resultat)
        cb(resultat[1]['money'])
    end)
end)

ESX.RegisterServerCallback('burgetshot:getPlayerSkin', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source);

    MySQL.Async.fetchAll('SELECT skin FROM users WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(users)
        local user, skin = users[1]

        local jobSkin = {
            skin_male   = xPlayer.job.skin_male,
            skin_female = xPlayer.job.skin_female
        }

        if user.skin then
            skin = json.decode(user.skin)
        end

        cb(skin, jobSkin)
    end)
end)

ESX.RegisterServerCallback("GetInventoryPlayer", function(src, cb)
    local xPlayer = ESX.GetPlayerFromId(src)
    cb(xPlayer.getInventory(true))
end)

for k,v in pairs(BurgerShotConfig.UtilisableItem) do
    ESX.RegisterUsableItem(k, function(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeInventoryItem(k,1)
        TriggerClientEvent('esx_status:add', source, 'hunger', v)
        TriggerClientEvent('esx_basicneeds:onEat', source)
    end)
end