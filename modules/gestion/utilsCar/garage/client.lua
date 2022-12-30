local menuOpen = false
local AntiSpam = true
local start = 1
local choseActuel = nil
local CarDispo = nil
local vehiclePerso = nil
local vehicleCrew = nil
local autorisation = nil
local tableau = 
    {
      { Name = 'Personnel'},
      { Name ='Crew'},
      { Name ='Entreprise'},
    }

local RageUIMenuGarage = RageUI.CreateMenu('Garage', 'Vos véhicules')
RageUIMenuGarage.Closed = function()
    menuOpen = false
end

local GetPersoVehiclePlayer = function()
    ESX.TriggerServerCallback("garage:GetOwnerVehicle", function(result)
        vehiclePerso = result
    end)
end


local GetCrewVehiclePlayer = function()
    ESX.TriggerServerCallback("garage:GetSharedVehicle", function(result)
        vehicleCrew = result
    end)
end


local GetSocietyVehiclePlayer = function()
    ESX.TriggerServerCallback("garage:GetSocietyVehicle", function(result)
        vehicleEntreprise = result
    end, ESX.GetPlayerData().job.name)
end


local MenuGarageSpawnVehicle = function(pointSpawn)
    if menuOpen == false then
        menuOpen = true
        vehiclePerso = nil
        GetPersoVehiclePlayer()
        GetCrewVehiclePlayer()
        if ESX.GetPlayerData().job.name ~= 'unemployed' then
            GetSocietyVehiclePlayer()
            while vehicleEntreprise == nil do Wait(5) end
        end
        while vehiclePerso == nil do Wait(5) end
        while vehicleCrew == nil do Wait(5) end
        RageUI.Visible(RageUIMenuGarage, true)
        CreateThread(function()
            while menuOpen == true do
                Wait(0)
                RageUI.IsVisible(RageUIMenuGarage, function()
                    RageUI.List("Choix des véhicules", tableau, start, nil, {}, true, {
                        onListChange = function(Index)
                            if (start ~= Index) then
                                start = Index
                            end
                        end,
                        onActive = function()
                            if choseActuel ~= start then
                                choseActuel = start
                            end
                        end
                    })
                    if choseActuel == 1 then
                        if json.encode(vehiclePerso) ~= '[]' then 
                            RageUI.Separator('↓ ~g~Vos Véhicule Personnel~s~ ↓')
                            for k,v in pairs(vehiclePerso)  do
                                RageUI.Button(v.NameCar..' - ~b~'..v.plate, nil, {RightLabel= '→→'}, v.park == true, {
                                    onSelected = function()
                                        if ESX.Game.IsSpawnPointClear(pointSpawn, 5) == true then
                                            TriggerServerEvent('garage:SetVehicleStatu', v.plate)
                                            ESX.Game.SpawnVehicle(v.spawnNameCar, pointSpawn, 0.0, function(carSpawn)
                                                ESX.Game.SetVehicleProperties(carSpawn, json.decode(v.custom))
                                                SetPedIntoVehicle(PlayerPedId(), carSpawn, -1)
                                            end)
                                            RageUI.CloseAll()
                                            menuOpen = false
                                        else
                                            ESX.ShowNotification("~r~Garage ~s~\nLa sortie du garage n'est pas libre", true, true, nil)
                                        end
                                    end
                                })
                            end
                        else
                            RageUI.Separator()
                            RageUI.Separator("Vous n'avez pas de ~r~véhicule")
                            RageUI.Separator()
                        end
                    elseif choseActuel == 2 then
                        if vehicleCrew == false then
                            RageUI.Separator()
                            RageUI.Separator("Vous n'avez pas la ~r~permission~s~ / pas de ~r~crew")
                            RageUI.Separator()
                        elseif json.encode(vehicleCrew) ~= '[]' then
                            RageUI.Separator('↓ ~g~Vos Véhicule Crew~s~ ↓')
                            for k,v in pairs(vehicleCrew)  do
                                RageUI.Button(v.NameCar..' - ~b~'..v.plate, nil, {RightLabel= '→→'}, v.park == true, {
                                    onSelected = function()
                                       if ESX.Game.IsSpawnPointClear(pointSpawn, 5) == true then
                                            RageUI.CloseAll()
                                            menuOpen = false
                                            ESX.ShowNotification("~r~Garage ~s~\nVérification de la disponibilité du véhicule...", true, true, nil)
                                            Wait(math.random(1000, 2000))
                                            ESX.TriggerServerCallback("garage:ChekIfPossible", function(result)
                                                CarDispo = result
                                            end, v.plate)
                                            while CarDispo == nil do Wait(5) end
                                            if CarDispo == true then
                                                TriggerServerEvent('garage:SetVehicleStatu', v.plate)
                                                ESX.Game.SpawnVehicle(v.spawnNameCar, pointSpawn, 0.0, function(carSpawn)
                                                    ESX.Game.SetVehicleProperties(carSpawn, json.decode(v.custom))
                                                    SetPedIntoVehicle(PlayerPedId(), carSpawn, -1)
                                                end)
                                            else
                                                ESX.ShowNotification("~r~Garage ~s~\nVéhicule déjà sorti", true, true, nil)
                                            end
                                        else
                                            ESX.ShowNotification("~r~Garage ~s~\nLa sortie du garage n'est pas libre", true, true, nil)
                                        end
                                    end
                                })
                            end
                        else
                            RageUI.Separator()
                            RageUI.Separator("Vous n'avez pas véhicule de ~r~crew")
                            RageUI.Separator()
                        end
                    elseif choseActuel == 3 then
                        if ESX.GetPlayerData().job.name ~= 'unemployed' then
                            if json.encode(vehicleEntreprise) ~= '[]' then 
                                RageUI.Separator('↓ ~g~Vos Véhicule Entreprise~s~ ↓')
                                for k,v in pairs(vehicleEntreprise)  do
                                    RageUI.Button(v.NameCar..' - ~b~'..v.plate, nil, {RightLabel= '→→'}, v.park == true, {
                                        onSelected = function()
                                            if ESX.Game.IsSpawnPointClear(pointSpawn, 5) == true then
                                                RageUI.CloseAll()
                                                menuOpen = false
                                                ESX.ShowNotification("~r~Garage ~s~\nVérification de la disponibilité du véhicule...", true, true, nil)
                                                Wait(math.random(1000, 2000))
                                                ESX.TriggerServerCallback("garage:ChekIfPossible", function(result)
                                                    CarDispo = result
                                                end, v.plate)
                                                while CarDispo == nil do Wait(5) end
                                                if CarDispo == true then
                                                    TriggerServerEvent('garage:SetVehicleStatu', v.plate)
                                                    ESX.Game.SpawnVehicle(v.spawnNameCar, pointSpawn, 0.0, function(carSpawn)
                                                        ESX.Game.SetVehicleProperties(carSpawn, json.decode(v.custom))
                                                        SetPedIntoVehicle(PlayerPedId(), carSpawn, -1)
                                                    end)
                                                else
                                                    ESX.ShowNotification("~r~Garage ~s~\nVéhicule déjà sorti", true, true, nil)
                                                end
                                            else
                                                ESX.ShowNotification("~r~Garage ~s~\nLa sortie du garage n'est pas libre", true, true, nil)
                                            end
                                        end
                                    })
                                end
                            end
                        else
                            RageUI.Separator()
                            RageUI.Separator("Vous n'avez pas de ~r~véhicule")
                            RageUI.Separator()
                        end
                    end
                end)
            end
        end)
    end
end

-- 76

CreateThread(function ()
    while true do
        local interval = 700
        for i = 1, #Garage do
            local playerPosition = GetEntityCoords(PlayerPedId())

            local dstMenuGarage = #(playerPosition - Garage[i].MenuGarage)
            local dstDeleteVehicle = #(playerPosition -  Garage[i].DeleteVehicle)
                if dstMenuGarage <= 10 then
                    interval = 0
                    DrawMarker(36, Garage[i].MenuGarage, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 1.0, 1.0, 1.0, 35, 202, 251, 255, false, false, false, true) 
                    if dstMenuGarage <= 2 then
                        if IsControlJustPressed(0, 38) then
                            MenuGarageSpawnVehicle(Garage[i].SpawnVehicle)
                        end
                    end
                end
                if (dstDeleteVehicle <= 10) and (IsPedInAnyVehicle(PlayerPedId(), false) == 1) then
                    interval = 0
                    DrawMarker(24, Garage[i].DeleteVehicle, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.7, 0.7, 0.7, 236, 74, 74, 255, false, false, false, true)
                    if dstDeleteVehicle <= 2 then
                        if IsControlJustPressed(0, 38) then
                            if AntiSpam == true then
                                local car = GetVehiclePedIsIn(PlayerPedId(),false)
                                local plate = GetVehicleNumberPlateText(car)
                                local custom = ESX.Game.GetVehicleProperties(car)
                                -- print(custom.bodyHealth)
                                -- print(custom.engineHealth)
                                ESX.TriggerServerCallback("garage:StoreCar", function(result)
                                    autorisation = result
                                end, plate, custom)
                                while autorisation == nil do Wait(5) end
                                if autorisation == true then
                                    ESX.Game.DeleteVehicle(car)
                                    ESX.ShowNotification("~r~Garage ~s~\nVous avez ranger le véhicule", true, true, nil)
                                else
                                    ESX.ShowNotification("~r~Garage ~s~\nVous ne pouvez pas ranger ce véhicule", true, true, nil)
                                end
                                AntiSpam = false
                                SetTimeout(2500, function()
                                    AntiSpam = true
                                end)
                            end
                        end
                    end
                end
            end
        Wait(interval)
    end
end)
