
local allOfHouses = {}

RegisterNetEvent('AgentImmo:CreateHouse')
AddEventHandler('AgentImmo:CreateHouse', function(name, price, coords, mailbox, typeMaison, maxCoffre)
    MySQL.Async.insert('INSERT INTO maisons (nom, position, prix, mailbox, proprietaire, typeMaison, maxCoffre) VALUES (@nom, @position, @prix, @mailbox, @proprietaire, @typeMaison, @maxCoffre);', {
        ["@nom"] = name,
        ["@position"] = json.encode(coords),
        ["@prix"] = price,
        ["@mailbox"] = json.encode(mailbox),
        ["@proprietaire"] = NULL,
        ["@typeMaison"] = json.encode(typeMaison),
        ["@maxCoffre"] = maxCoffre,
    })
    TriggerEvent('AgentImmo:RefreshHousesServer')
end)


RegisterNetEvent('AgentImmo:EnterInHouse')
AddEventHandler('AgentImmo:EnterInHouse', function(bucket)
    local src = source
    SetPlayerRoutingBucket(src,bucket)
end)

RegisterNetEvent('AgentImmo:ExitHouse')
AddEventHandler('AgentImmo:ExitHouse', function(bucket)
    local src = source
    SetPlayerRoutingBucket(src,0)
end)


RegisterNetEvent('AgentImmo:onResourceStartRefreshHouses')
AddEventHandler('AgentImmo:onResourceStartRefreshHouses', function()
    local src = source
    TriggerClientEvent('AgentImmo:RefreshHouses', src, allOfHouses)
end)

AddEventHandler('onResourceStart', function(ressource)
    TriggerEvent('AgentImmo:RefreshHousesServer')
end)
  

RegisterNetEvent('AgentImmo:RefreshHousesServer')
AddEventHandler('AgentImmo:RefreshHousesServer', function()
    MySQL.Async.fetchAll('SELECT * FROM maisons ',{}, function(resultat)
        for k,v in pairs(resultat) do
            if not allOfHouses[k] then
                allOfHouses[k] = {
                    id = v.id,
                    nom = v.nom,
                    position = json.decode(v.position),
                    prix = v.prix,
                    mailbox = json.decode(v.mailbox),
                    proprietaire = v.proprietaire,
                    identifier = v.identifier,
                    optionnal = v.optionnal,
                    typeMaison = json.decode(v.typeMaison),
                    maxCoffre = v.maxCoffre,
                }
            end
        end
        TriggerClientEvent('AgentImmo:RefreshHouses', -1, allOfHouses)
    end)
end)
