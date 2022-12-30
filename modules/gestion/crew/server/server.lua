local ChekIfCrewIsTrue = function(name, cb)
    MySQL.Async.fetchAll('SELECT * FROM crew WHERE name = @name', {
        ["name"] = name,
    },function(resultat)
        cb(resultat)
    end)
end

local ChekIfRankOfCrewIsTrue = function(crew, grade, cb)
    MySQL.Async.fetchAll('SELECT * FROM crew WHERE name = @name AND grade = @grade', {
        ["name"] = crew,
        ["grade"] = grade,
    },function(resultat)
        cb(resultat)
    end)
end

local SetCrewPlayer = function(player, crew, grade)
    MySQL.Async.execute('UPDATE `users` SET crew_name = "'..crew..'", crew_grade = "'..grade..'" WHERE identifier = "'..player..'"')
end

local SetRankOfCrewPlayer = function(player, grade)
    MySQL.Async.execute('UPDATE `users` SET crew_grade = "'..grade..'" WHERE identifier = "'..player..'"')
end

local ClearCrewPlayers = function(CrwName, CrwRank)
    MySQL.Async.fetchAll('SELECT identifier FROM users WHERE crew_name = @CrwName AND crew_grade = @CrwRank', {
        ["CrwName"] = CrwName,
        ["CrwRank"] = CrwRank,
    },function(resultat)
        for k,v in pairs(resultat)do
            MySQL.Async.execute('UPDATE users SET crew_name = @crew_name, crew_grade = @CrwRank WHERE identifier = @compte ', {
                ['@crew_name'] = NULL,
                ["@crew_grade"] = NULL,
                ["@compte"] = v.identifier,
            })
        end
    end)
end

local DeleteCrewPlayers = function(CrwName)
    MySQL.Async.fetchAll('SELECT identifier FROM users WHERE crew_name = @CrwName ', {
        ["CrwName"] = CrwName,
    },function(resultat)
        for k,v in pairs(resultat)do
            MySQL.Async.execute('UPDATE users SET crew_name = @crew_name, crew_grade = @CrwRank WHERE identifier = @compte ', {
                ['@crew_name'] = NULL,
                ["@crew_grade"] = NULL,
                ["@compte"] = v.identifier,
            })
        end
    end)
end


ESX.RegisterServerCallback('crew:GetRankCrew', function(source, cb) 
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT crew_name, crew_grade FROM users WHERE identifier = @player', {
        ["player"] = xPlayer.identifier,
    },function(resultat)
        MySQL.Async.fetchAll('SELECT permission_gestion FROM crew WHERE name = @name AND grade = @grade', {
            ["name"] = resultat[1].crew_name,
            ["grade"] = resultat[1].crew_grade,
        },function(resultat2)
            cb(resultat, resultat2)
        end)
    end)

end)

ESX.RegisterServerCallback('crew:GetAllRankCrew', function(source, cb, name) 
    local src = source

    MySQL.Async.fetchAll('SELECT * FROM crew WHERE name = @name', {
        ["name"] = name,
    },function(resultat)
        cb(resultat)
    end)

end)



ESX.RegisterServerCallback('crew:GetCrewOwner', function(source, cb, crew) 
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT owner FROM crew WHERE name = @compte', {
        ["compte"] = crew,
    },function(resultat)
        if xPlayer.identifier == resultat[1]["owner"] then
            cb(true)
        else
            cb(false)
        end
    end)

end)


ESX.RegisterServerCallback('crew:GetPermissionOfRank', function(source, cb, crew, rank) 
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.fetchAll('SELECT permission_gestion, permision_bank, permision_car FROM crew WHERE name = @compte AND grade = @rank', {
        ["compte"] = crew,
        ["rank"] = rank,
    },function(resultat)
        cb(resultat)
    end)

end)

ESX.RegisterServerCallback('crew:GetAllMembreOfCrew', function(source, cb, crew) 
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local name = xPlayer.getName()
    MySQL.Async.fetchAll('SELECT identifier, firstname, lastname, crew_grade FROM users WHERE crew_name = @crew', {
        ["crew"] = crew,
    },function(resultat)
        cb(resultat, name)
    end)

end)

RegisterNetEvent('crew:DeleteRank')
AddEventHandler('crew:DeleteRank', function(crew, nameOfRank)
    ClearCrewPlayers(crew, nameOfRank)
    MySQL.Async.execute('DELETE FROM crew WHERE name = @crew AND grade = @nameOfRank ', {
        ['@crew'] = crew,
        ['@nameOfRank'] = nameOfRank,
    })
end)

RegisterNetEvent('crew:ExitCrew')
AddEventHandler('crew:ExitCrew', function(crew)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.execute('UPDATE users SET crew_name = @crew_name, crew_grade = @CrwRank WHERE identifier = @compte ', {
        ['@crew_name'] = NULL,
        ["@crew_grade"] = NULL,
        ["@compte"] = xPlayer.identifier,
    })
    xPlayer.showNotification("~r~Crew création\n~s~Vous venez de quitter le crew ~b~"..crew, true, true)
end)


RegisterNetEvent('crew:DeleteCrew')
AddEventHandler('crew:DeleteCrew', function(crew)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    DeleteCrewPlayers(crew)
    MySQL.Async.execute('DELETE FROM crew WHERE name = @crew', {
        ['@crew'] = crew,
    })
    MySQL.Async.execute('DELETE FROM banque WHERE allow = @crew', {
        ['@crew'] = crew,
    })
    xPlayer.showNotification("~r~Crew création\n~s~Vous venez de supprimé le crew ~b~"..crew, true, true)
end)



RegisterNetEvent('crew:ChangeRank')
AddEventHandler('crew:ChangeRank', function(crew, nameOfRank, newPlayer, firstname, lastname)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    ChekIfRankOfCrewIsTrue(crew, nameOfRank, function(resultat)
        if json.encode(resultat) ~= '[]' then
            SetRankOfCrewPlayer(newPlayer, nameOfRank)
            xPlayer.showNotification("~r~Crew création\n~s~Vous venez de modifié le grade de ~b~"..firstname..' '..lastname..'~s~ pour le grade ~g~'..nameOfRank, true, true)
        else
            xPlayer.showNotification("~r~Crew création\n~s~Le grade que vous avez choisi n'exsiste pas")
        end
    end)
end)


RegisterNetEvent('crew:KickPlayerCrew')
AddEventHandler('crew:KickPlayerCrew', function(player, first, last)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    MySQL.Async.execute('UPDATE users SET crew_name = @crew_name, crew_grade = @CrwRank WHERE identifier = @compte ', {
        ['@crew_name'] = NULL,
        ["@crew_grade"] = NULL,
        ["@compte"] = player,
    })
    xPlayer.showNotification("~r~Crew création\n~s~Vous avez exclu ~b~"..first..' '..last..' ~s~de votre crew')
end)


RegisterNetEvent('crew:UpdateRank')
AddEventHandler('crew:UpdateRank', function( NameOfCrew, nameOfRank, accesCompte, accesGestion, accesVehicle)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local cmp1 = 0
    local gest1 = 0
    local vhcl1 = 0

    if accesCompte == true then
        cmp1 = 1
    end
    
    if accesGestion == true then
        gest1 = 1
    end
    
    if accesVehicle == true then
        vhcl1 = 1
    end
    MySQL.Async.execute('UPDATE `crew` SET permission_gestion = "'..gest1..'", permision_bank = "'..cmp1..'", permision_car = "'..vhcl1..'" WHERE grade = "'..nameOfRank..'" AND name = "'..NameOfCrew..'"')
    xPlayer.showNotification("~r~Crew création\n~s~Vous venez de modifié le rang ~b~"..nameOfRank, true, true)
end)

RegisterNetEvent('crew:CreateNewRank')
AddEventHandler('crew:CreateNewRank', function( NameOfCrew, newRank, accesCompte, accesGestion, accesVehicle)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local cmp = 0
    local gest = 0
    local vhcl = 0

    if accesCompte == true then
        cmp = 1
    end
    if accesGestion == true then
        gest = 1
    end
    if accesVehicle == true then
        vhcl = 1
    end

    MySQL.Async.fetchAll('SELECT grade FROM crew WHERE name = @compte AND grade = @rank', {
        ["compte"] = NameOfCrew,
        ["rank"] = newRank,
    },function(resultat)
        if json.encode(resultat) == '[]' then
            MySQL.Async.insert('INSERT INTO crew ( owner, name, grade, permission_gestion, permision_bank, permision_car) VALUES (@owner, @name, @grade, @permission_gestion, @permision_bank, @permision_car);', {
                ["@owner"] = xPlayer.identifier,
                ["@name"] = NameOfCrew,
                ["@grade"] = newRank,
                ["@permission_gestion"] = gest,
                ["@permision_bank"] = cmp,
                ["@permision_car"] = vhcl,
            })
            xPlayer.showNotification("~r~Crew création\n~s~Vous venez de créé le rang : ~b~"..newRank, true, true)
        else
            xPlayer.showNotification("~r~Crew création\n~s~Le rang ~b~"..newRank..' ~s~existe déjà', true, true)
        end

    end)
end)


RegisterNetEvent('crew:CreateCrew')
AddEventHandler('crew:CreateCrew', function(name, grade, notif)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

        ChekIfCrewIsTrue(name, function(resultat)
            if json.encode(resultat) == '[]' then
                MySQL.Async.insert('INSERT INTO crew ( owner, name, grade, permission_gestion, permision_bank, permision_car) VALUES (@owner, @name, @grade, @permission_gestion, @permision_bank, @permision_car);', {
                    ["@owner"] = xPlayer.identifier,
                    ["@name"] = name,
                    ["@grade"] = grade,
                    ["@permission_gestion"] = 1,
                    ["@permision_bank"] = 1,
                    ["@permision_car"] = 1,
                })
                SetCrewPlayer(xPlayer.identifier, name, grade)
                xPlayer.showNotification("~r~Crew création\n~s~Vous venez de créé votre crew : "..notif, true, true)
            else
                xPlayer.showNotification("~r~Crew création\n~s~Il existe déjà un crew avec ce nom", true, true)
            end
        end)

end)

