local menuOpen = false
local CategorieSelected = nil
local actualVehicleName = nil
local DeleteVehicleName = nil
local vehicleSelected = nil
local menuShopConcess = RageUI.CreateMenu('Concessionnaire', "Catégorie")
menuShopConcess.Closed = function()
    menuOpen = false
    Horizon.DeleteCam(concessCam, {Anim = true, AnimTime = 2000})
    ESX.Game.DeleteVehicle(DeleteVehicleName)
end

local SubmenuShopConcess = RageUI.CreateSubMenu(menuShopConcess,'Concessionnaire',"Véhicules")
local MenuBuyCar = RageUI.CreateSubMenu(SubmenuShopConcess,'Concessionnaire',"Véhicules")

ConcessMenu = function()
    if menuOpen == false then
        menuOpen = true
        RageUI.Visible(menuShopConcess, true)
        CreateThread(function ()
            while menuOpen == true do
                Wait(0)
                RageUI.IsVisible(menuShopConcess, function()
                    for k,v in pairs(Concess.Cars) do
                        RageUI.Button(k, nil, {RightLabel = '→→'}, true, {
                            onSelected = function()
                               CategorieSelected = v
                            end
                        }, SubmenuShopConcess)
                    end
                end)
                RageUI.IsVisible(SubmenuShopConcess, function()
                   if CategorieSelected ~= nil then
                        for k,v in pairs(CategorieSelected) do
                            RageUI.Button(k, nil, {RightLabel = '~b~'..v.price..' $'}, true, {
                                onActive = function()
                                    if actualVehicleName ~= nil then
                                        SetEntityHeading(DeleteVehicleName, GetEntityHeading(DeleteVehicleName)+0.4)
                                    end
                                    if v.spawnName ~= actualVehicleName then
                                        ESX.Game.DeleteVehicle(DeleteVehicleName)
                                        actualVehicleName = v.spawnName
                                        ESX.Game.SpawnLocalVehicle(v.spawnName, Concess.PointSpawnCar, heading, function(vehicle)
                                            DeleteVehicleName = vehicle
                                        end)
                                    end
                                end,
                                onSelected = function()
                                    vehicleSelected = {
                                        NameSpawn = v.spawnName,
                                        Price = v.price,
                                        NameCar = k,
                                    }
                                end
                            }, MenuBuyCar)
                        end
                   end
                end)
                RageUI.IsVisible(MenuBuyCar, function()
                    if vehicleSelected ~= nil then
                        RageUI.Separator('Nom du véhicule : ~b~'..vehicleSelected.NameCar)
                        RageUI.Separator('Prix : ~g~'..vehicleSelected.Price..' $')
                        RageUI.Button('Acheter le véhicule', nil, {RightLabel = '→→'}, true, {
                            onActive = function()
                                if actualVehicleName ~= nil then
                                    SetEntityHeading(DeleteVehicleName, GetEntityHeading(DeleteVehicleName)+0.4)
                                end
                            end,
                            onSelected = function()
                               TriggerServerEvent('concess:BuyCar', vehicleSelected.NameCar, vehicleSelected.Price, vehicleSelected.NameSpawn)
                            end
                        })
                    end
                end)
            end
        end)
    end
end

RegisterNetEvent('concess:GiveCar')
AddEventHandler('concess:GiveCar', function(plate, spawnName, nameCar)
    Horizon.DeleteCam(concessCam, {Anim = true, AnimTime = 1000})
    ESX.Game.DeleteVehicle(DeleteVehicleName)
    ESX.Game.SpawnVehicle(spawnName, Concess.SpawnCar, 0.0, function(vehicle)
        SetVehicleNumberPlateText(vehicle, plate)
        SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    end)
    ESX.ShowAdvancedNotification("Concessionnaire", "Achat", "Vous venez d'acheter un/e ~b~"..nameCar.."~s~ avec la plaque ~g~"..plate, "CHAR_CARSITE", 1, true, true)
    RageUI.CloseAll()
    menuOpen = false
end)

Citizen.CreateThread(function()
    while true do 
        local interval = 700
        local ped = PlayerPedId()
        local playerPosition = GetEntityCoords(ped)
        local dstShopVecile = #(playerPosition - Concess.PointShopVehicle)

        if dstShopVecile <= 5 then
            interval = 0
            DrawMarker(23, Concess.PointShopVehicle, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
            if dstShopVecile <= 1.5 then
                AddTextEntry("concess", "Appuyez sur ~INPUT_PICKUP~ pour ouvrir le ~b~concessionnaire ")
                DisplayHelpTextThisFrame("concess", false)
                if IsControlJustPressed(0, 38) then
                    concessCam = Horizon.CreateCamera({Concess.PositionCam.x, Concess.PositionCam.y, Concess.PositionCam.z, rotY = -25.0, heading = -120.0, fov = 50.0, AnimTime = 2500})
                    Wait(2500)
                    ConcessMenu()
                end
            end
        end
        Wait(interval)
    end
end)

