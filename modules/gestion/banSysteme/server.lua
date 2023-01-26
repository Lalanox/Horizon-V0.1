time = (os.time())+8759
print(time)
timeLeft = (time - os.time())/3600
print('Il vous reste '..timeLeft..' heures avant la fin de votre ban.')
date = os.date("%d/%m/%Y", time)
print(date)

RegisterNetEvent('banSysteme:ban')
AddEventHandler('banSysteme:ban',function(target, reason, time)
    local xPlayer = ESX.GetPlayerFromId(source)

    if xPlayer.getGroup() == 'moderateur' or xPlayer.getGroup() == 'administrateur' or xPlayer.getGroup() == 'superadmin' or xPlayer.getGroup() == 'fondateur' then
        local xTarget = ESX.GetPlayerFromId(target)
        local targetIdentifier = xTarget.getIdentifier()
        local targetId = xTarget.id
    
        local SourceName = xPlayer.getName()
        local newTime = time*3600
        local endTime = os.time()+newTime
        print(newTime, endTime)
        MySQL.Async.execute("INSERT INTO ban (identifier, uniqueID, reason, author, startTime, endTime) VALUES (@identifier, @uniqueID, @reason, @author, @startTime, @endTime)", {
            ['@identifier'] = targetIdentifier,
            ['@uniqueID'] = targetId,
            ['@reason'] = reason,
            ['@author'] = SourceName,
            ['@startTime'] = os.time(),
            ['@endTime'] = endTime,
        })
        DropPlayer(target, 'Horizon \n Vous avez été banni pour la raison suivante : '..reason..' \n Par :'..SourceName..'\n Durée : '..time..' heures.')
    else
        -- BAN  ANTI - CHEAT
    end
end)

