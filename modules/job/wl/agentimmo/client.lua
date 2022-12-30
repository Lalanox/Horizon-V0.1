local menuOpened = false
local mainMenu = RageUI.CreateMenu('Agent Immo', 'Gestion du travail')
local maisons = {}
local houseSelected = nil
local playerInHouse = false
local subMenuHouses = RageUI.CreateSubMenu(mainMenu, 'Maisons', 'Creation de maison')
local subMenuHousesSelected = RageUI.CreateSubMenu(subMenuHouses, 'Maisons', 'Choix de la maison')
mainMenu.Closed = function()
    menuOpened = false
end

local mainMenuEnter = RageUI.CreateMenu('Maison', 'Entrée de la maison')
mainMenuEnter.Closed = function()
    menuOpened = false
end

local function advancedGoto(coords, time, cb)
    DoScreenFadeOut(time * 500);
    Wait(time * 500);
    SetEntityCoords(PlayerPedId(), coords);
    if cb then cb() end
    Wait(time * 500);
    DoScreenFadeIn(time * 500);
end

local function ExitOneHouse(t)
    CreateThread(function()
        while playerInHouse == true do
            local interval3 = 700
            local pPosition = GetEntityCoords(PlayerPedId())
            for k,v in pairs(AgentImmmo.ExitPose) do 
                local distance2 = #(pPosition - v)

                if distance2 <= 1.5 then
                    interval3 = 0
                    ESX.ShowHelpNotification('Appui sur  ~INPUT_CONTEXT~ pour sortir de la propriété')
                    if IsControlJustPressed(0, 38) then
                        local houseCoords2 = vector3(t.position.x, t.position.y, t.position.z)
                        advancedGoto(houseCoords2, 1, function()
                            TriggerServerEvent('AgentImmo:ExitHouse')
                            RageUI.CloseAll()
                            menuOpened = false
                            playerInHouse = false
                        end)
                    end
                end
            end
            Wait(interval3)
        end
    end)
end

local function EnterInHouse(set)
    if menuOpened == false then
        menuOpened = true
        RageUI.Visible(mainMenuEnter, true)
        CreateThread(function()
            while menuOpened do
                RageUI.IsVisible(mainMenuEnter, function()
                    RageUI.Separator('Nom de la propriété : ~b~'.. set.nom)
                    if set.proprietaire == NULL then
                        RageUI.Separator('Prix : ~g~'.. ESX.Math.GroupDigits(set.prix)..' $')
                        RageUI.Button('Acheter la propriété', 'Veuilliez contacter ~b~l\'agent immobilier~s~ pour acheter cette propriété', {}, false, {})
                    elseif set.identifier == ESX.GetPlayerData().identifier then
                        RageUI.Button('Entré dans votre maison', nil, {}, true, {
                            onSelected = function()
                                houseSelected = set
                                playerInHouse = true
                                local houseToTp = vector3(set.typeMaison.x, set.typeMaison.y, set.typeMaison.z)
                                advancedGoto(houseToTp, 1, function()
                                    TriggerServerEvent('AgentImmo:EnterInHouse', set.id)
                                    RageUI.CloseAll()
                                    menuOpened = false
                                end)
                                ExitOneHouse(houseSelected)
                            end
                        })
                    end
                end)
                Wait(0)
            end
        end)
    end
end


local function CreateHouseMenu()
    local state1 = '~r~ Non définie'
    local state2 = '~r~ Non définie'
    local state3 = '~r~ Non définie'
    local state4 = '~r~ Non définie'

    local finalCoordsLettres = nil
    local finalCoords = nil
    local definitivePrice = nil
    local definitiveName = nil
    local apartSelect = {
        select = 'Aucun'
    }

    if menuOpened == false then
        menuOpened = true
        RageUI.Visible(mainMenu, true)
        CreateThread(function ()
            while menuOpened == true do
                Wait(0)
                RageUI.IsVisible(mainMenu, function()
                    RageUI.Button('Crée une maison', nil, {RightLabel = '→→'}, true, {}, subMenuHouses)
                end)
                RageUI.IsVisible(subMenuHouses, function()
                    RageUI.Button('Nom de la maison', nil, {RightLabel = state1}, true, {
                        onSelected = function()
                            local nom = nil 
                            nom = Horizon.KeyboardInput('HOUSES_NAME', "Veuillez entrer le nom de la maison", "", 20)
                            if nom ~= nil then
                                state1 = '~b~'..nom
                                definitiveName = nom 
                            else
                                ESX.ShowNotification("~r~Agent Immobilier\n~s~Vous n'avez pas entré de nom", true, true)
                            end
                        end
                    })
                    RageUI.Button('Prix de la maison', nil, {RightLabel = state2}, true, {
                        onSelected = function()
                            local price = nil 
                            price = Horizon.KeyboardInput('HOUSES_PRICE', "Veuillez entrer le prix de la maison", "", 8)
                            if Horizon.isInteger(price) and price ~= nil then
                                state2 = '~g~'..price..' $'
                                definitivePrice = price 
                            else
                                ESX.ShowNotification("~r~Agent Immobilier\n~s~Vous n'avez pas entré un bon nombre", true, true)
                            end
                        end
                    })
                    RageUI.Separator('________________')
                    RageUI.Button('Porte de la maison', nil, {RightLabel = state3}, true, {
                        onSelected = function()
                            local coords = GetEntityCoords(PlayerPedId())
                            local corectly = GetGroundZFor_3dCoord(coords.x,coords.y,coords.z, true)
                            finalCoords = vector3(coords.x, coords.y, coords.z-corectly+0.035)
                            state3 = '~b~ Définie'
                            ESX.ShowNotification("~r~Agent Immobilier\n~s~Vous avez défini la porte de la maison", true, true)
                        end
                    })
                    RageUI.Button('Type de la maison', nil, {RightLabel = '→→'}, true, {
                        onSelected = function()
                            
                        end
                    }, subMenuHousesSelected)
                    RageUI.Separator('________________')
                    RageUI.Button('Boite aux lettres', nil, {RightLabel = state4}, true, {
                        onSelected = function()
                            local coordsV2 = GetEntityCoords(PlayerPedId())
                            local corectlyV2 = GetGroundZFor_3dCoord(coordsV2.x,coordsV2.y,coordsV2.z, true)
                            finalCoordsLettres = vector3(coordsV2.x, coordsV2.y, coordsV2.z-corectlyV2+0.035)
                            state4 = '~b~ Définie'
                            ESX.ShowNotification("~r~Agent Immobilier\n~s~Vous avez défini la boite aux lettres", true, true)
                        end
                    })
                    RageUI.Separator('________________')
                    RageUI.Button('Crée la propriété', nil, {RightLabel = '→→', Color = {BackgroundColor={110,228,137,200}}}, true, {
                        onSelected = function()
                            if finalCoords ~= nil and definitiveName ~= nil and definitivePrice ~= nil and finalCoordsLettres ~= nil and apartSelect.select ~= 'Aucun' then
                                RageUI.CloseAll()
                                menuOpened = false
                                print("Création de la maison", finalCoords, finalCoordsLettres)
                                ESX.ShowNotification("~r~Agent Immobilier\n~s~Vous avez crée la maison ~b~"..definitiveName.."~s~ dans la rue ~b~"..Horizon.getStreetName(finalCoords), true, true)
                                TriggerServerEvent('AgentImmo:CreateHouse', definitiveName, definitivePrice, finalCoords, finalCoordsLettres, apartSelect.tp, apartSelect.coffre)
                            else
                                ESX.ShowNotification("~r~Agent Immobilier\n~s~Vous n'avez pas défini toutes les informations", true, true)
                            end
                        end
                    })
                end)
                RageUI.IsVisible(subMenuHousesSelected, function()
                    RageUI.Separator('_____Appartement_____')
                    for k,v in pairs(AgentImmmo.Possibility['Appartement']) do
                        if apartSelect.name == v.name then
                            RageUI.Button(v.name, nil, {RightLabel = '~b~ Séléctionner'}, true, {})
                        else
                            RageUI.Button(v.name, nil, {}, true, {
                                onActive = function()
                                    RenderSprite('agentImmo', v.img, v.posImg.x, v.posImg.y, 400, 400)
                                end,
                                onSelected = function()
                                    apartSelect = {
                                        name = v.name,
                                        tp = v.tp,
                                        coffre = v.coffre,
                                    }
                                end
                            })
                        end
                    end
                    RageUI.Separator('_____Hangar_____')
                    for k,v in pairs(AgentImmmo.Possibility['Hangar']) do
                        if apartSelect.name == v.name then
                            RageUI.Button(v.name, nil, {RightLabel = '~b~ Séléctionner'}, true, {})
                        else
                            RageUI.Button(v.name, nil, {}, true, {
                                onSelected = function()
                                    apartSelect = {
                                        name = v.name,
                                        tp = v.tp,
                                        coffre = v.coffre,
                                    }
                                end
                            })
                        end
                    end
                end)
            end
        end)
    end
end

RegisterNetEvent('AgentImmo:RefreshHouses')
AddEventHandler('AgentImmo:RefreshHouses', function(result)
    maisons = result
end)


CreateThread(function()
    TriggerServerEvent('AgentImmo:onResourceStartRefreshHouses')
    while true do
        local interval = 700
        local playerPosition = GetEntityCoords(PlayerPedId())
        for k,v in pairs(maisons) do
            local houseCoords = vector3(v.position.x, v.position.y, v.position.z)
            local dstPlayerMaison = #(playerPosition - houseCoords)
            if dstPlayerMaison <= 3.5 then
                interval = 0
                DrawMarker(6, houseCoords, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, 0.6, 0.6, 0.6, 35, 202, 251, 255, false, false, 0, false, nil, nil, false)
                if dstPlayerMaison <= 1.5 then
                    ESX.ShowHelpNotification('Appui sur  ~INPUT_CONTEXT~ pour ouvrir le menu')
                    if IsControlJustPressed(0, 38) then
                        EnterInHouse(v)
                    end
                end
            end
        end
        Wait(interval)
    end
end)

CreateThread(function()
    while true do
        local interval2 = 700
        local playerPosition2 = GetEntityCoords(PlayerPedId())
        for j,f in pairs(maisons) do
            local mailboxCoords = vector3(f.mailbox.x, f.mailbox.y, f.mailbox.z)
            local dstPlayerMailbox = #(playerPosition2 - mailboxCoords)
            if dstPlayerMailbox <= 3.5 then
                interval2 = 0
                DrawMarker(6, mailboxCoords, 0.0, 0.0, 0.0, 270.0, 0.0, 0.0, 0.6, 0.6, 0.6, 35, 202, 251, 255, false, false, 0, false, nil, nil, false)
            end
        end
        Wait(interval2)
    end
end)

Keys.Register(AgentImmmo.InputMenuHouse, 'menuHouse', 'Menu entreprise Agent Immmobilier', function()
    if ESX.GetPlayerData().job.name == 'immobilier' then
        CreateHouseMenu()
    end
end)

RegisterCommand('tp', function(rawCommand, args)
    SetEntityCoords(PlayerPedId(), vector3(tonumber(args[1]),tonumber(args[2]), tonumber(args[3])))
end)

RegisterCommand("debug", function()
    TriggerScreenblurFadeOut(500);
    DoScreenFadeIn(500);
    SetPlayerControl(PlayerId(), true, 12);
    ClearPedTasks(PlayerPedId());
end)
