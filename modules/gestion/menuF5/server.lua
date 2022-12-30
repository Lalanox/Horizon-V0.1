local staffActif = {}
local Reports = {}
local idReport = 0

RegisterNetEvent('administartion:takeStaff')
AddEventHandler('administartion:takeStaff', function(type)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local player = xPlayer.getIdentifier()
    if type == 'add' then
        if not staffActif[player] then
            staffActif[player] = tonumber(src)
            for k,v in pairs(staffActif) do
                print("value", v)
                TriggerClientEvent("administration:notifStaff", tonumber(v), xPlayer.getName(), 'on')
            end
        end
    elseif type == 'off' then
        if staffActif[player] then
            staffActif[player] = nil;
            for k,v in pairs(staffActif) do
                TriggerClientEvent("administration:notifStaff", tonumber(v), xPlayer.getName(), 'off')
            end
        end
    end
end)

RegisterNetEvent('administration:ActionAdmin')
AddEventHandler('administration:ActionAdmin', function(action, target, message, message2)
    local src = source
    local itsOkay = false
    local xPlayer = ESX.GetPlayerFromId(src)
    local xTarget = ESX.GetPlayerFromId(target)
    if xPlayer.getGroup() == 'moderateur' or xPlayer.getGroup() == 'administrateur' or xPlayer.getGroup() == 'superadmin' or xPlayer.getGroup() == 'fondateur' then
        if action == 'goto' then
            local toCoords = GetEntityCoords(GetPlayerPed(target))
            SetEntityCoords(GetPlayerPed(src), toCoords, false, false, false, false)
        elseif action == 'bring' then
            local toCoords = GetEntityCoords(GetPlayerPed(src))
            SetEntityCoords(GetPlayerPed(target), toCoords, false, false, false, false)
        elseif action == 'kick' then
            DropPlayer(target, 'Horizon : Vous avez été kick pour la raison suivante - '..message)
        elseif action == 'message' then
            xPlayer.showNotification('~r~Administration ~s~\n Vottre message a été envoyé à ~b~'..xTarget.getName())
            xTarget.showNotification('~r~Message du staff~s~\n'..message)
        elseif action == 'delWarn' then
            MySQL.Async.execute('DELETE FROM `warns` WHERE `id` = @id', {['@id'] = message2})
            xPlayer.showNotification('~r~Administration ~s~\nVotre avertissement a été supprimé')
        elseif action == 'addWarn' then
            MySQL.Async.execute('INSERT INTO `warns` (`identifier`, `raison`, `auteur`, `date`) VALUES (@identifier, @raison, @auteur, @date)', {['@identifier'] = xTarget.getIdentifier(), ['@raison'] = message, ['@auteur'] = xPlayer.getName(), ['@date'] = GetDateLocalString()})
            xPlayer.showNotification('~r~Administration ~s~\nVotre avertissement a été ajouté')
            xTarget.showNotification('~r~Attention~s~\nVous avez reçu un avertissement pour la raison suivante : ~b~'..message)
        elseif action == 'giveItem' then
            for k,v in pairs(ESX.Items) do
                itsOkay = true
            end 
            if itsOkay == true then
                xTarget.addInventoryItem(message, message2)
                xPlayer.showNotification('~r~Administration ~s~\nVous avez donné ~b~'..Horizon.StyleText(message)..'~s~ avec ~b~'..message2..'~s~ quantité à ~g~'..xTarget.getName())
                xTarget.showNotification('~r~Administration ~s~\nVous avez reçu un(e) ~b~'..Horizon.StyleText(message)..'~s~ avec ~b~'..message2..'~s~ quantité ')
            else
                xPlayer.showNotification('~r~Administration ~s~\nCet item n\'existe pas')
            end
        elseif action == 'giveMoney' then
            xTarget.addMoney(message)
            xPlayer.showNotification('~r~Administration ~s~\nVous avez donné ~g~'..message..'$~s~ à ~b~'..xTarget.getName())
            xTarget.showNotification('~r~Administration ~s~\nVous avez reçu ~g~'..message..'$~s~')
        end
    end
end)


RegisterNetEvent('print')
AddEventHandler('print', function(text)
    print(text)
end)

ESX.RegisterServerCallback('administration:warnsPlayer', function(source, cb, joueur)
    print(joueur)
    local xTarget = ESX.GetPlayerFromId(joueur);
    local identifier = xTarget.getIdentifier();
    local result = MySQL.Sync.fetchAll("SELECT * FROM warns WHERE identifier = @identifier", {
        ['@identifier'] = identifier
    })
    if result then
        cb(result)
    else
        cb(false)
    end
end)

function GetDateLocalString()
    local date = os.date('*t')
    return string.format('%02d/%02d/%04d', date.day, date.month, date.year)
end

ESX.RegisterServerCallback('administration:getAllItems', function(source, cb)   
    cb(ESX.Items)
end)

ESX.RegisterServerCallback('administration:inventairePlayer', function(source, cb, joueur)
    local xPlayer = ESX.GetPlayerFromId(joueur)
    local items = xPlayer.getInventory(1)
    cb(items)
end)

ESX.RegisterServerCallback('administration:getListPlayer', function(source, cb)
    local Players = ESX.GetPlayers()
    local list = {}
    for i=1, #Players do
        local xPlayer = ESX.GetPlayerFromId(Players[i])
        table.insert(list, {
            name = xPlayer.getName(),
            job = xPlayer.getJob(),
            source = xPlayer.source,
            id_unique = xPlayer.id, 
            group = xPlayer.getGroup()
        })
    end
    cb(list)
end)

ESX.RegisterServerCallback('Horizon-menuF5:getGroup', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb(xPlayer.getGroup())
end)

