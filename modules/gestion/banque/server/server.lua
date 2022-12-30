ESX.RegisterServerCallback('banque:ChekCompte', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT * FROM banque WHERE player = @player', {
        ["player"] = xPlayer.identifier,
    },function(resultat)
        cb(resultat)
    end)
end)


ESX.RegisterServerCallback('banque:InfoPlayer', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth FROM users WHERE identifier = @player', {
        ["player"] = xPlayer.identifier,
    },function(resultat)
        cb(resultat)
    end)
end)


ESX.RegisterServerCallback('banque:chekAccountCrew', function(source, cb, crew, rank)
    
    MySQL.Async.fetchAll('SELECT * FROM banque WHERE allow = @crew', {
        ["crew"] = crew,
    },function(resultat)
        MySQL.Async.fetchAll('SELECT permision_bank FROM crew WHERE name = @crew AND grade = @rank', {
            ["crew"] = crew,
            ["rank"] = rank,
        },function(second)
            if json.encode(resultat) == '[]' then
                if second[1].permision_bank == true then
                    cb('allowCreation')
                else 
                    cb('NotallowCreation')
                end
            else
                if second[1].permision_bank == true then
                    cb(resultat)
                else
                    cb('NotAllow')
                end
            end
        end)

    end)

end)

ESX.RegisterServerCallback('banque:societyPlayer', function(source, cb, playerSociety)
    local src = source

    MySQL.Async.fetchAll('SELECT money FROM addon_account_data WHERE account_name = @compte', {
        ["compte"] = playerSociety,
    },function(resultat)
        cb(resultat[1].money)
    end)

end)


ESX.RegisterServerCallback('banque:LogsAccountsRet', function(source, cb, compte)
    local src = source

    MySQL.Async.fetchAll('SELECT * FROM banque_log WHERE emetteur = @compte AND type = @type', {
        ["compte"] = compte,
        ["type"] = 'Retrait',
    },function(resultat)
        cb(resultat)
    end)
end)

ESX.RegisterServerCallback('banque:LogsAccountsDep', function(source, cb, compte)
    local src = source

    MySQL.Async.fetchAll('SELECT * FROM banque_log WHERE emetteur = @compte AND type = @type', {
        ["compte"] = compte,
        ["type"] = 'Dépôt',
    },function(resultat)
        cb(resultat)
    end)
end)

ESX.RegisterServerCallback('banque:LogsAccountsVirRecu', function(source, cb, compte)
    local src = source

    MySQL.Async.fetchAll('SELECT * FROM banque_log WHERE recepteur = @compte', {
        ["compte"] = compte,
    },function(resultat)
        cb(resultat)
    end)
end)

ESX.RegisterServerCallback('banque:LogsAccountsVirEnv', function(source, cb, compte)
    local src = source

    MySQL.Async.fetchAll('SELECT * FROM banque_log WHERE emetteur = @compte AND type = @type ', {
        ["compte"] = compte,
        ["type"] = 'Envoyer',
    },function(resultat)
        cb(resultat)
    end)
end)

ESX.RegisterServerCallback('banque:accountPlayer', function(source, cb)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT * FROM banque WHERE player = @player AND shared = @shared', {
        ["player"] = xPlayer.identifier,
        ["shared"] = 0,
    },function(resultat)
        cb(resultat)
    end)
end)


RegisterNetEvent('banque:Logs')
AddEventHandler('banque:Logs', function(sourcePlayer ,type, compte, montant, lieu, destinataire)
    local xPlayer = ESX.GetPlayerFromId(sourcePlayer)
    local time = os.date("%x")
    local name = xPlayer.getName()

    if type == 'Dépôt' then
        
        MySQL.Async.insert('INSERT INTO banque_log ( emetteur, montant, type, lieu, date, auteur) VALUES (@compte, @montant, @type, @lieu, @date, @auteur);', {
            ["@compte"] = compte,
            ["@montant"] = montant,
            ["@type"] = type,
            ["@lieu"] = lieu,
            ["@date"] = time,
            ["@auteur"] = name,
        })

    elseif type == 'Retrait' then

        MySQL.Async.insert('INSERT INTO banque_log ( emetteur, montant, type, lieu, date, auteur) VALUES (@compte, @montant, @type, @lieu, @date, @auteur);', {
            ["@compte"] = compte,
            ["@montant"] = montant,
            ["@type"] = type,
            ["@lieu"] = lieu,
            ["@date"] = time,
            ["@auteur"] = name,
        })

    elseif type == 'Envoyer' then

        MySQL.Async.insert('INSERT INTO banque_log ( emetteur, recepteur, montant, type, lieu, date, auteur) VALUES (@compte, @otherCompte, @montant, @type, @lieu, @date, @auteur);', {
            ["@compte"] = compte,
            ["@otherCompte"] = destinataire,
            ["@montant"] = montant,
            ["@type"] = type,
            ["@lieu"] = lieu,
            ["@date"] = time,
            ["@auteur"] = name,
        })

    end
end)


RegisterNetEvent('banque:doVirement')
AddEventHandler('banque:doVirement', function(comptePlayer, soldePlayer, OtherAccount, amount, where)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT solde FROM banque WHERE compte = @compte', {
        ["compte"] = OtherAccount,
    },function(resultat)
        if json.encode(resultat) == '[]' then
            xPlayer.showNotification("~r~Banque\n~s~Le compte que vous avez choisi n'existe pas", true, true)
        else
            local newMoney = tonumber(resultat[1]['solde']) + amount
            local moneyPlayer = tonumber(soldePlayer) - amount
            MySQL.Async.execute('UPDATE banque SET solde = @solde WHERE compte = @compte ', {
                ['@solde'] = newMoney,
                ["@compte"] = OtherAccount,
            })

            MySQL.Async.execute('UPDATE banque SET solde = @solde WHERE compte = @compte ', {
                ['@solde'] = moneyPlayer,
                ["@compte"] = comptePlayer,
            })
            TriggerEvent('banque:Logs', src,'Envoyer', comptePlayer, amount, where, OtherAccount)
            xPlayer.showNotification("~r~Banque\n~s~Vous avez effectuez un virement de ~b~"..amount..'$~s~ sur le compte ~b~N°'..OtherAccount, true, true)
        end
    end)

end)


RegisterNetEvent('banque:deleteAccount')
AddEventHandler('banque:deleteAccount', function(compte)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT compte FROM banque WHERE player = @player', {
        ["player"] = xPlayer.identifier,
    },function(resultat)
        for k,v in pairs(resultat) do 
            if v.compte == compte then
                MySQL.Async.execute('DELETE FROM banque WHERE compte = @compte ', {
                    ['@compte'] = compte,
                })
            end
        end
    end)
end)


RegisterNetEvent('banque:changeStatu')
AddEventHandler('banque:changeStatu', function(compte)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)


    MySQL.Async.execute('UPDATE banque SET actuel = @statu WHERE player = @player AND shared = @shared', {
        ['@statu'] = 0,
        ["@player"] = xPlayer.identifier,
        ["@shared"] = 0,
    })
    Wait(100)
    MySQL.Async.execute('UPDATE banque SET actuel = @otherStatu WHERE compte = @compte ', {
        ['@otherStatu'] = 1,
        ["@compte"] = compte,
    })

end)


RegisterNetEvent('banque:money')
AddEventHandler('banque:money', function(statu, compte, Money, where)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local walletMoney = xPlayer.getMoney(src)


    MySQL.Async.fetchAll('SELECT solde FROM banque WHERE compte = @compte', {
        ["compte"] = compte,
    },function(resultat)
        if statu == 'rmv' then
                local soldeCompte = resultat[1].solde
                if tonumber(Money) <= tonumber(soldeCompte) then
                    local moneyForUpdate = tonumber(soldeCompte) - tonumber(Money)
                    MySQL.Async.execute('UPDATE banque SET solde = @solde WHERE compte = @compte ', {
                        ['@solde'] = moneyForUpdate,
                        ["@compte"] = compte,
                    })
                    xPlayer.addMoney(Money)
                    xPlayer.showNotification('~r~Banque\n~s~Vous avez retire ~g~'..Money..' $~s~ du compte ~b~N° '..compte)
                    TriggerEvent('banque:Logs',  src,'Retrait', compte, Money, where)
                else
                    xPlayer.showNotification('~r~Banque\n~s~Vous n\'avez pas assez d\'argent sur le compte ~b~N° '..compte)
                end
        elseif statu == 'add' then
            local soldeCompte = resultat[1].solde
            if tonumber(Money) <= tonumber(walletMoney) then
                local moneyForUpdate = tonumber(soldeCompte) + tonumber(Money)
                MySQL.Async.execute('UPDATE banque SET solde = @solde WHERE compte = @compte ', {
                    ['@solde'] = moneyForUpdate,
                    ["@compte"] = compte,
                })
                xPlayer.removeMoney(Money)
                xPlayer.showNotification('~r~Banque\n~s~Vous avez déposer ~g~'..Money..' $~s~ sur le compte ~b~N° '..compte)
                TriggerEvent('banque:Logs',  src,'Dépôt', compte, Money, where)
            else
                xPlayer.showNotification('~r~Banque\n~s~Vous n\'avez pas assez d\'argent sur vous ')
            end
        end
    end)
end)


RegisterNetEvent('banque:createAccount')
AddEventHandler('banque:createAccount', function(newOrNot, nameCrew)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if newOrNot == 'new' then

        MySQL.Async.insert('INSERT INTO banque ( player, solde, actuel) VALUES (@player, @solde, @actuel);', {
            ["@player"] = xPlayer.identifier,
            ["@solde"] = 0,
            ["@actuel"] = 1,
        })
    
    elseif newOrNot == 'notNew' then

        MySQL.Async.insert('INSERT INTO banque ( player, solde, actuel) VALUES (@player, @solde, @actuel);', {
            ["@player"] = xPlayer.identifier,
            ["@solde"] = 0,
            ["@actuel"] = 0,
        })

    elseif newOrNot == 'newShared' then

        MySQL.Async.insert('INSERT INTO banque (player, solde, actuel, shared, allow) VALUES (@player, @solde, @actuel, @shared, @allow);', {
            ["@player"] = 'compte crew',
            ["@solde"] = 0,
            ["@actuel"] = 0,
            ["@shared"] = 1,
            ["@allow"] = nameCrew,
        })
    
    end

end)

RegisterNetEvent('banque:updateMoneySociety')
AddEventHandler('banque:updateMoneySociety', function(statu, playerSociety, moneyRmv)
    local src = source 
    local xPlayer = ESX.GetPlayerFromId(src)
    local plyMoney = xPlayer.getMoney()

    MySQL.Async.fetchAll('SELECT money FROM addon_account_data WHERE account_name = @compte', {
        ["compte"] = playerSociety,
    },function(resultat)
        if statu == 'sup' then
            if tonumber(resultat[1].money) >= tonumber(moneyRmv) then
                local newMontant = tonumber(resultat[1].money) - tonumber(moneyRmv)
                MySQL.Async.execute('UPDATE addon_account_data SET money = @solde WHERE account_name = @compte ', {
                    ['@solde'] = newMontant,
                    ["@compte"] = playerSociety,
                })
                xPlayer.addMoney(moneyRmv)
                xPlayer.showNotification('~r~Banque\n~s~Vous avez retirer ~g~'..moneyRmv..' $~s~ de votre société')
            else
                xPlayer.showNotification('~r~Banque\n~s~Vous n\'avez pas assez d\'argent sur votre compte société ')
            end
        elseif statu == 'ad' then
            if tonumber(moneyRmv) <= tonumber(plyMoney)then
                local newMontant = tonumber(resultat[1].money) + tonumber(moneyRmv)
                MySQL.Async.execute('UPDATE addon_account_data SET money = @solde WHERE account_name = @compte ', {
                    ['@solde'] = newMontant,
                    ["@compte"] = playerSociety,
                })
                xPlayer.removeMoney(moneyRmv)
                xPlayer.showNotification('~r~Banque\n~s~Vous avez déposer ~g~'..moneyRmv..' $~s~ dans votre société')
            else
                xPlayer.showNotification('~r~Banque\n~s~Vous n\'avez pas assez d\'argent sur vous ')
            end
        end
    end)
end)