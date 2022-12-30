local PlayerData = {}
local NecessariItems = {}
local InventoryJob = {}
local Inventory = {}
local BurgerSelect = nil;
local menuOpen = false
local pressed = false
local FoodTruckSorti = false
local PlayerInFoodTruck = false
local PlayerInBoss = false
local tableau = {1,2,3,4,5,6,7,8,9,10}
local _TRGSV = TriggerServerEvent;



local BurgerShot = RageUI.CreateMenu("BURGER SHOT", "Employes")
BurgerShot.Closed = function()
    menuOpen = false;
    NecessariItems = {}
end

local FoodTruckBurgerShot = RageUI.CreateMenu("BURGER SHOT", "Employes")
FoodTruckBurgerShot.Closed = function()
    menuOpen = false;
    NecessariItems = {}
end

local ShowMenuPatron = RageUI.CreateMenu("BURGER SHOT", "Gestion")
ShowMenuPatron.Closed = function()
    menuOpen = false;
    PlayerInBoss = false
end


local ShowMenuShopItem = RageUI.CreateMenu("BURGER SHOT", "Magasin")
ShowMenuShopItem.Closed = function()
    menuOpen = false;
end

local AddStock = RageUI.CreateSubMenu(BurgerShot, "BURGER SHOT", "Stock")
local TakeInStock = RageUI.CreateSubMenu(BurgerShot, "BURGER SHOT", "Stock")
local BurgerShotCraftBurger = RageUI.CreateSubMenu(BurgerShot, "BURGER SHOT", "Ingredients")
local BurgerShotCraftFrite = RageUI.CreateSubMenu(BurgerShot, "BURGER SHOT", "Ingredients")
local MenuArgentSociete = RageUI.CreateSubMenu(ShowMenuPatron, "BURGER SHOT", "Gestion Argent")


KeyboardInput = function(title, TextEntry, ExampleText, MaxStringLenght)

	AddTextEntry(title, TextEntry) 
	DisplayOnscreenKeyboard(1, title, "", ExampleText, "", "", "", MaxStringLenght) 
	blockinput = true 

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() 
		Citizen.Wait(500) 
		blockinput = false 
		return result 
	else
		Citizen.Wait(500) 
		blockinput = false 
		return nil 
	end
end

UpdateJobPlayer = function()
    PlayerData = ESX.GetPlayerData()
    -- print(json.encode(PlayerData['job']))
    for k, v in pairs(PlayerData) do
        if k == 'job'then
            value = json.encode(v.name)
        end
    end
    for k,v in pairs(PlayerData['job']) do
        if k == 'grade_name' then
            statu = v
        end
    end
end

StyleText = function (text)
    local result = ''
    if text ~= '' then
        result = string.format('%s%s',string.upper(string.sub(text,string.len(text)*-1,string.len(text)*-1)),string.sub(text, 2))
    end
    return result
end

ChekInventoryItems = function (NecessariItems)
    ESX.TriggerServerCallback("SendNecessarieItems", function(result)
        ican = result;
    end, NecessariItems)
end

GetInventoryOfPlayer = function ()
    ESX.TriggerServerCallback("GetInventoryPlayer", function (result)
        Inventory = result
    end)
end

GetInventoryOfJob = function ()
    ESX.TriggerServerCallback("GetInventoryJob", function (result)
        InventoryJob = result
    end)
end

CreateCamera = function(var)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
    SetCamActive(cam, true)
    SetCamParams(cam, var[1] or 10.0, var[2] or 10.0, var[3] or 10.0, var.rotY or 1.0, 0.0, var.heading or 200.0, 42.24, 0, 1, 1, 2)
    SetCamCoord(cam, var[1], var[2], var[3])
    SetCamFov(cam, var.fov or 40.0)
    RenderScriptCams(true, var.Anim or true, var.AnimTime or 0, true, true)
    return cam
end

DeleteCam = function(name, var)
    if DoesCamExist(name) then
        SetCamActive(name, false)
        DestroyCam(name, false, false)
        RenderScriptCams(false, var.Anim or true, var.AnimTime or 0, false, false)
    else
        print("ERROR - LA CAM N'EXISTE PAS")
    end
end

GetPlayerSkin = function ()
    ESX.TriggerServerCallback("burgetshot:getPlayerSkin", function (result)
        SkinPlayer = result
    end)
end

TenueJob = function(player)
    TriggerEvent('skinchanger:getSkin', function(skin)
        if skin.sex == 0 then
                TriggerEvent('skinchanger:loadClothes', skin, BurgerShot.Tenues.Male)
        elseif skin.sex == 1 then
                TriggerEvent('skinchanger:loadClothes', skin, BurgerShot.Tenues.Female)
        end
    end)
end 

TenueCivil = function(player)
    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
        TriggerEvent('skinchanger:loadSkin', skin)
    end) 
end 

MoneySociety = function()
    ESX.TriggerServerCallback('burgershot:GetMoneyInSociety', function(result)
        SocietyMoney = result
    end) 
end 

playAnimation = function(set)
    ClearPedTasksImmediately(PlayerPedId())
    RequestAnimDict(set.dict)
    while not HasAnimDictLoaded(set.dict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), set.dict, set.name, 8.0, 1.0, -1, 1)
    RemoveAnimDict(set.dict)
end

MenuShopItem = function() 
    if menuOpen == false then
        menuOpen = true
        RageUI.Visible(ShowMenuShopItem, true)
        CreateThread(function ()
            while menuOpen == true do 
                RageUI.IsVisible(ShowMenuShopItem, function()
                    for k,v in pairs(BurgerShotConfig.ItemsToBuy) do
                        RageUI.List(StyleText(k).." - ~g~"..v.price.."$", tableau, v.index, nil, {}, true, {
                            onListChange = function(Index)
                                if (Index ~= v.index) then
                                    v.index = Index;
                                end
                            end,
                            onSelected = function(Index)
                                _TRGSV("burgershot:shopItems", k, v.price, Index)
                            end
                        })
                    end
                end)
                Wait(0)
            end
        end)
    end
end

MenuCraftFoodTruck = function ()
    if menuOpen == false then
        menuOpen = true
        RageUI.Visible(FoodTruckBurgerShot, true)
        CreateThread(function ()
            while menuOpen == true do
                RageUI.IsVisible(FoodTruckBurgerShot, function()
                    RageUI.Button("Burger", nil, {RightLabel = '→→'}, true, {
                        onSelected = function ()
                            RageUI.CloseAll()
                            menuOpen = false
                            MenuBurgerShot('Burger')
                        end
                    })
                    RageUI.Button("Frite", nil, {RightLabel = '→→'}, true, {
                        onSelected = function ()
                            RageUI.CloseAll()
                            menuOpen = false
                            MenuBurgerShot('Frite')
                        end
                    })
                end)
                Wait(0)
            end
        end)
    end
end

MenuPatron = function()
    UpdateJobPlayer()
    while statu == nil do Wait(5) end 
    if statu == 'patron' then
        if menuOpen == false then
            menuOpen = true
            MoneySociety();
            while SocietyMoney == nil do Wait(5) end 
            RageUI.Visible(ShowMenuPatron, true)
            CreateThread(function()
                while menuOpen == true do
                    MoneySociety()
                    Wait(2000)
                end
            end)
            CreateThread(function ()
                while menuOpen == true do
                    Wait(0)
                    RageUI.IsVisible(ShowMenuPatron, function()
                        local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer();

                        RageUI.Separator("Argent dans la société : ~g~"..ESX.Math.GroupDigits(tonumber(SocietyMoney)).." $")
                        RageUI.Button("Virer de l'argent société", nil, {RightLabel = '→→'}, true, {},MenuArgentSociete)
                        RageUI.Button("Recruter / Promouvoir une personne", nil, {RightLabel = '→→'}, closestPlayer ~= -1 and closestPlayerDistance <= 3.0, {
                            onSelected = function()
                                if closestPlayer ~= -1 and closestPlayerDistance <= 3.0 then
                                    _TRGSV("burgershot:updateJob", 'add', GetPlayerServerId(closestPlayer))
                                else
                                    ESX.ShowNotification('~r~Burgershot~w~\nAucune personne autour de vous')
                                end
                            end,
                            onActive = function()
                                local player, distance = ESX.Game.GetClosestPlayer();
                                local pedPos = GetEntityCoords(GetPlayerPed(player));
                                if player ~= -1 and distance <= 3.0 then
                                    DrawMarker(20, pedPos.x, pedPos.y, pedPos.z+1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0, 255, 0, 1, 2, 1, nil, nil, 0);
                                end
                            end
                        })

                        RageUI.Button("Virer / Destituer une personne", nil, {RightLabel = '→→'}, closestPlayer ~= -1 and closestPlayerDistance <= 3.0, {
                            onSelected = function ()
                                if closestPlayer ~= -1 and closestPlayerDistance <= 3.0 then
                                    _TRGSV("burgershot:updateJob", 'rmv', GetPlayerServerId(closestPlayer))
                                else
                                    ESX.ShowNotification('~r~Burgershot~w~\nAucune personne autour de vous')
                                end
                            end,
                            onActive = function()
                                local player, distance = ESX.Game.GetClosestPlayer();
                                local pedPos = GetEntityCoords(GetPlayerPed(player));
                                if player ~= -1 and distance <= 3.0 then
                                    DrawMarker(20, pedPos.x, pedPos.y, pedPos.z+1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0, 255, 0, 1, 2, 1, nil, nil, 0);
                                end
                            end
                        })

                        RageUI.Button("Faire une facture", nil, {RightLabel = '→→'}, closestPlayer ~= -1 and closestPlayerDistance <= 3.0, {
                            onSelected = function()
                                if closestPlayer == -1 and closestPlayerDistance > 3.0 then
                                    ESX.ShowNotification('~r~Burgershot~w~\nAucune personne autour de vous')
                                else
                                    local PriceBilling = KeyboardInput("BILLING_BURGERSHOT", "Montant de la facture", "", 5)
                                    if tonumber(PriceBilling) then
                                        _TRGSV('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_burgershot', 'Burgershot', PriceBilling)
                                        ESX.ShowNotification('~r~Burgershot~w~\nVous avez fait une facture de ~g~'..PriceBilling..'$')
                                    else
                                        ESX.ShowNotification('~r~Burgershot~w~\nLe montant de la facture n\'est pas bon')
                                    end
                                end
                            end,
                            onActive = function()
                                local player, distance = ESX.Game.GetClosestPlayer();
                                local pedPos = GetEntityCoords(GetPlayerPed(player));
                                if player ~= -1 and distance <= 3.0 then
                                    DrawMarker(20, pedPos.x, pedPos.y, pedPos.z+1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0, 255, 0, 1, 2, 1, nil, nil, 0);
                                end
                            end
                        })

                        RageUI.Button("Aller au vendeur de produit", nil, {RightLabel = '→→'}, true, {
                            onSelected = function() 
                                SetNewWaypoint(BurgerShotConfig.Point.shopItems.x, BurgerShotConfig.Point.shopItems.y)
                                ESX.ShowNotification('~r~Burgershot~w~\nUn point sur votre ~b~GPS~w~ a été placer jusqu\'au fournisseur')
                            end
                        })
                    end)
                    RageUI.IsVisible(MenuArgentSociete, function()
                        RageUI.Button("~r~Retirer~s~ de l'argent de la société", nil, {RightLabel = '→→'}, true, {
                            onSelected = function()
                                removeMoneyS = KeyboardInput("REMOVEMONEY_INSOCIETY", "Retirer", "", 10)
                                if removeMoneyS ~= nil then
                                    _TRGSV('burgershot:removeMoneyInSociety', removeMoneyS)
                                end
                            end
                        })
                        RageUI.Button("~b~Ajouter~s~ de l'argent dans la société", nil, {RightLabel = '→→'}, true, {
                            onSelected = function()
                                addMoneyS = KeyboardInput("ADDMONEY_INSOCIETY" ,"Ajouter", "", 10)
                                if addMoneyS ~= nil then
                                    _TRGSV('burgershot:addMoneyInSociety', addMoneyS)
                                end        
                            end
                        })
                    end)
                end
            end)
        end
    else
        if menuOpen == false then
            menuOpen = true
            RageUI.Visible(ShowMenuPatron, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(ShowMenuPatron, function()
                        RageUI.Button("Faire une facture", nil, {RightLabel = '→→'}, true, {
                            onSelected = function() 
                                local closestPlayer, closestPlayerDistance = ESX.Game.GetClosestPlayer()
                                if closestPlayer ~= -1 or closestPlayerDistance <= 3.0 then
                                    local PriceBilling = KeyboardInput("BILLING_BURGERSHOT", "Montant de la facture", "", 5)
                                    if tonumber(PriceBilling) then
                                        _TRGSV('esx_billing:sendBill', GetPlayerServerId(closestPlayer), 'society_burgershot', 'Burgershot', PriceBilling)
                                        ESX.ShowNotification('~r~Burgershot~w~\nVous avez fait une facture de ~g~'..PriceBilling..'$')
                                    else
                                        ESX.ShowNotification('~r~Burgershot~w~\nLe montant de la facture n\'est pas bon')
                                    end
                                else
                                    ESX.ShowNotification('~r~Burgershot~w~\nPersonne autour de vous')
                                end
                            end,
                            onActive = function()
                                local player, distance = ESX.Game.GetClosestPlayer();
                                local pedPos = GetEntityCoords(GetPlayerPed(player));
                                if player ~= -1 and distance <= 3.0 then
                                    DrawMarker(20, pedPos.x, pedPos.y, pedPos.z+1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0, 255, 0, 1, 2, 1, nil, nil, 0);
                                end
                            end
                        })
                        RageUI.Button("Aller au vendeur de produit", nil, {RightLabel = '→→'}, true, {
                            onSelected = function() 
                                SetNewWaypoint(BurgerShotConfig.Point.shopItems.x, BurgerShotConfig.Point.shopItems.y)
                                ESX.ShowNotification('~r~Burgershot~w~\nUn point sur votre ~b~GPS~w~ a été placer jusqu\'au fournisseur')
                            end
                        })
                    end)
                    Wait(0)
                end
            end)
        end
    end
end

MenuBurgerShot = function(value)
    if value == 'Burger'then
        if menuOpen == false then
            menuOpen = true
            RageUI.Visible(BurgerShot, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(BurgerShot, function()
                        for k,v in pairs(BurgerShotConfig.Burger) do
                            RageUI.Button(StyleText(k), nil, {RightLabel = '→→'}, true, {
                                onActive = function()
                                    NecessariItems = {}
                                    BurgerSelect = k;
                                    while BurgerSelect == nil do Wait(5) end
                                    for k,v in pairs(BurgerShotConfig.Burger[BurgerSelect]) do
                                        NecessariItems[k] = {
                                            quantiti = v,
                                            name = BurgerSelect,
                                            };
                                    end
                                end
                            }, BurgerShotCraftBurger)
                        end
                    end)
                    RageUI.IsVisible(BurgerShotCraftBurger, function()
                        RageUI.Separator("↓ Vous avez besoin des ~g~ingrédients~w~ ↓")
                        RageUI.Separator("------------------------")
                        for k,v in pairs(BurgerShotConfig.Burger[BurgerSelect]) do
                            RageUI.Button(StyleText(k), nil, {RightLabel = "x~b~"..v}, true, {RightLabel = '→→'});
                        end
                        RageUI.Separator("------------------------")
                        RageUI.Button("                    Cuissiner le ~b~"..BurgerSelect, nil, {RightLabel = '→→'}, true, {
                            onSelected = function ()
                                ChekInventoryItems(NecessariItems)
                                Wait(100)
                                if ican == false then
                                    ESX.ShowNotification("~r~Burgershot~w~\nVous n'avez pas les ingrédients nécéssaire", true, true, nil)
                                else
                                    if PlayerInFoodTruck == false then
                                        SetEntityHeading(PlayerPedId(), 120.0)
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        RageUI.CloseAll()
                                        menuOpen = false
                                        TaskStartScenarioInPlace(PlayerPedId(),"PROP_HUMAN_BBQ",-1, true)
                                        Wait(BurgerShotConfig.Time.craftBurger)
                                        ClearPedTasksImmediately(PlayerPedId())
                                        FreezeEntityPosition(PlayerPedId(), false)
                                    else
                                        RageUI.CloseAll()
                                        menuOpen = false
                                        TaskStartScenarioInPlace(PlayerPedId(),"PROP_HUMAN_BBQ",-1, true)
                                        Wait(BurgerShotConfig.Time.craftBurger)
                                        ClearPedTasksImmediately(PlayerPedId())
                                    end
                                end
                            end
                        })
                    end)
                    Wait(0)
                end
            end)
        end
    end
    if value == 'Frite'then
        if menuOpen == false then
            menuOpen = true
            RageUI.Visible(BurgerShot, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(BurgerShot, function ()
                        for k,v in pairs(BurgerShotConfig.Frites) do
                            RageUI.Button(StyleText(k), nil, {RightLabel = '→→'}, true, {
                                onActive = function()
                                    NecessariItems = {}
                                    FriteSelect = k
                                    for k,v in pairs(BurgerShotConfig.Frites[FriteSelect]) do
                                        NecessariItems[k] = {
                                            quantiti = v,
                                            name = FriteSelect,
                                            };
                                    end
                                end
                            }, BurgerShotCraftFrite)
                        end
                    end)
                    RageUI.IsVisible(BurgerShotCraftFrite, function ()
                        RageUI.Separator("↓ Vous avez besoin des ~g~ingrédients~w~ ↓")
                        RageUI.Separator("------------------------")
                        for k,v in pairs(BurgerShotConfig.Frites[FriteSelect]) do
                            RageUI.Button(StyleText(k), nil, {RightLabel = "x~b~"..v}, true, {})
                        end
                        RageUI.Separator("------------------------")
                        RageUI.Button("                    Cuissiner ~b~"..FriteSelect, nil, {RightLabel = '→→'}, true, {
                            onSelected = function ()
                                ChekInventoryItems(NecessariItems)
                                while ican == nil do Wait(5) end
                                if ican == false then
                                    ESX.ShowNotification("~r~Burgershot~w~\nVous n'avez pas les ingrédients nécéssaire", true, true, nil)
                                else
                                    if PlayerInFoodTruck == false then
                                        SetEntityHeading(PlayerPedId(), 120.0)
                                        FreezeEntityPosition(PlayerPedId(), true)
                                        RageUI.CloseAll()
                                        menuOpen = false
                                        TaskStartScenarioInPlace(PlayerPedId(),"PROP_HUMAN_BBQ",-1, true)
                                        Wait(BurgerShotConfig.Time.craftFrite)
                                        ClearPedTasksImmediately(PlayerPedId())
                                        FreezeEntityPosition(PlayerPedId(), false)
                                    else
                                        RageUI.CloseAll()
                                        menuOpen = false
                                        TaskStartScenarioInPlace(PlayerPedId(),"PROP_HUMAN_BBQ",-1, true)
                                        Wait(BurgerShotConfig.Time.craftFrite)
                                        ClearPedTasksImmediately(PlayerPedId())
                                    end
                                end
                            end
                        })
                    end)
                    Wait(0)
                end
            end)
        end
    end
    if value == 'car'then
        if menuOpen == false then
            menuOpen = true
            GetPlayerSkin()
            RageUI.Visible(BurgerShot, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(BurgerShot, function ()
                        RageUI.Button("Sortir le Food Truck", nil, {RightLabel = '→→'}, true, {
                            onSelected = function ()
                               if ESX.Game.IsSpawnPointClear(BurgerShotConfig.Point.carSpawnPoint, 5) == true then
                                interval_car = 700
                                    ESX.Game.SpawnVehicle('taco', BurgerShotConfig.Point.carSpawnPoint, 0, function (vehicleS)
                                        SetVehicleNumberPlateText(vehicleS, "BGR SHOT")
                                        SetPedIntoVehicle(PlayerPedId(), vehicleS, -1)
                                        RageUI.CloseAll()
                                        menuOpen = false
                                        FoodTruckSorti = true
                                        while FoodTruckSorti == true do
                                            Wait(interval_car) 
                                            if GetEntitySpeed(vehicleS) <= 0 and (IsPedInAnyVehicle(PlayerPedId(), false) == false ) then
                                                interval_car = 0
                                                local vehiculePosition = GetEntityCoords(vehicleS)
                                                local vehiculeHeading = GetEntityHeading(vehicleS)
                                                local cos = math.cos((vehiculeHeading*math.pi)/180)
                                                local sin = math.sin((vehiculeHeading*math.pi)/180)
                                                local ped = PlayerPedId()
                                                local playerPosition = GetEntityCoords(ped)
                                                local dstCarPlayer = #(playerPosition - vector3(vehiculePosition.x + sin*5 , vehiculePosition.y-cos*5, vehiculePosition.z))
                                                local dstCarPlayerFoodMenu  = #(playerPosition -vector3(vehiculePosition.x + sin , vehiculePosition.y-cos, vehiculePosition.z))
                                                DrawMarker(20, vehiculePosition.x + sin*5 , vehiculePosition.y-cos*5, vehiculePosition.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, false)
                                                if dstCarPlayer <= 1.0  then
                                                    AddTextEntry("foodtruck", "Appuyez sur ~INPUT_PICKUP~ pour rentrer dans le ~g~Food Truck")
                                                    DisplayHelpTextThisFrame("foodtruck", false)
                                                    if IsControlJustPressed(0, 38) then
                                                        pressed = true
                                                        PlayerInFoodTruck = true
                                                        camera = CreateCamera({vehiculePosition.x + cos*5 , vehiculePosition.y+sin*5, vehiculePosition.z+1.5, rotY = -10.0, heading = vehiculeHeading+90.0, fov = 50.0, AnimTime = 1500})
                                                        FreezeEntityPosition(ped, true)
                                                        SetEntityCoords(ped,  vehiculePosition.x , vehiculePosition.y, vehiculePosition.z-0.4)
                                                        SetEntityHeading(ped, vehiculeHeading-90.0)
                                                        SetVehicleDoorOpen(vehicleS, 5, true, true)
                                                        Visual.Subtitle("Appuyer sur ~b~[E]~s~ pour Cuissiner / ~b~[H]~s~ pour quitter le camion", 5000)
                                                    end
                                                end
                                                if dstCarPlayerFoodMenu <= 2.0 then
                                                    if pressed == true then
                                                        if IsControlJustPressed(0, 38) then
                                                            MenuCraftFoodTruck()
                                                        end
                                                        if IsControlJustPressed(0, 101) then
                                                            pressed = false
                                                            PlayerInFoodTruck = false
                                                            SetVehicleDoorShut(vehicleS, 5, true, false)
                                                            DeleteCam(camera, {Anim = true, AnimTime = 1500})
                                                            SetEntityCoords(ped, vehiculePosition.x + sin*5, vehiculePosition.y-cos*5, vehiculePosition.z)
                                                            FreezeEntityPosition(ped, false)
                                                        end
                                                    end
                                                end
                                            end
                                        end
                                    end)
                                else
                                    ESX.ShowNotification("~r~Burgershot~w~\nla zone n'est pas libre", true, true, nil)
                               end 
                            end
                        })
                        RageUI.Button("Sortir le véhicule de livraison", nil, {RightLabel = '→→'}, true, {
                            onSelected = function ()
                                ESX.Game.SpawnVehicle('mule', BurgerShotConfig.Point.carSpawnPoint, 0, function (vehicleL)
                                    SetVehicleNumberPlateText(vehicleL, "BGR SHOT")
                                    SetPedIntoVehicle(PlayerPedId(), vehicleL, -1)
                                    RageUI.CloseAll()
                                    menuOpen = false
                                end)
                            end
                        })
                        RageUI.Button("Prendre sa tenue de travail", nil, {RightLabel = '→→'}, true, {
                            onSelected = function ()
                                TenueJob(PlayerPedId())
                            end
                        })
                        RageUI.Button("Prendre sa tenue civil", nil, {RightLabel = '→→'}, true, {   
                            onSelected = function ()
                                TenueCivil(PlayerPedId())
                            end
                        })
                    end)
                    Wait(0)
                end
            end)
        end
    end
    if value == 'deleteCar'then
        if menuOpen == false then
            menuOpen = true
            RageUI.Visible(BurgerShot, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(BurgerShot, function()
                        RageUI.Button("Rentrer le Food Truck", nil, {RightLabel = '→→'}, true, {
                            onSelected = function ()
                                FoodTruckSorti = false
                                local car = GetVehiclePedIsIn(PlayerPedId(),false)
                                local plate = GetVehicleNumberPlateText(car)

                                if plate == 'BGR SHOT'then 
                                    ESX.Game.DeleteVehicle(car)
                                else
                                    ESX.ShowNotification("~r~Burgershot~w~\nce n'est pas un véhicule de la société", true, true, nil)                               
                                end
                                RageUI.CloseAll()
                                menuOpen = false
                            end
                        })
                    end)
                    Wait(0)
                end
            end)
        end
    end
    if value == 'Frigo'then
        if menuOpen == false then
            menuOpen = true
            RageUI.Visible(BurgerShot, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(BurgerShot, function()
                        RageUI.Button("Ajouter au stock", nil, {RightLabel = '→→'}, true, {
                            onSelected = function()
                                GetInventoryOfPlayer()
                            end
                        }, AddStock)
                        RageUI.Button("Retirer du stock", nil, {RightLabel = '→→'}, true, {
                            onSelected = function()
                                GetInventoryOfJob()
                            end
                        }, TakeInStock)
                    end)
                    RageUI.IsVisible(AddStock, function()
                        if json.encode(Inventory) ~='[]' then
                            for k,v in pairs(Inventory) do
                                print(v)
                                if v > 0 then
                                    RageUI.Button(StyleText(k)..' ~w~(~b~'..v..'~w~)', nil, {RightLabel = "→→"}, true, {
                                        onSelected = function ()
                                            countItems = KeyboardInput("ADDITEM_BURGERSHOT","Déposer", "", 4)
                                            if countItems ~= nil then
                                                _TRGSV("burgershot:AddItems", countItems, k)
                                                RageUI.GoBack()
                                            end
                                        end
                                    })
                                end
                            end
                        else
                            RageUI.Separator(' ')
                            RageUI.Separator(' Vous avez ~r~aucun~s~ item sur vous')
                            RageUI.Separator(' ')
                        end
                    end)
                    RageUI.IsVisible(TakeInStock, function()
                        if #InventoryJob > 0 then
                            for k,v in pairs(InventoryJob) do
                                if v.count > 0 then
                                    RageUI.Button(StyleText(v.name).." ~w~(~b~"..v.count.."~w~)", nil, {RightLabel = "→→"}, true, {
                                        onSelected = function ()
                                            countItemsSelect = tonumber(KeyboardInput("REMOVEITEM_BURGERSHOT","Retirer", "", 4))
                                            if countItemsSelect ~= nil and countItemsSelect <= tonumber(v.count) then
                                                _TRGSV("burgershot:DeleteItems", countItemsSelect, v.name)
                                                RageUI.GoBack()
                                            end
                                        end
                                    })
                                end
                            end
                        else
                            RageUI.Separator(' ')
                            RageUI.Separator(' Vous avez ~r~aucun~s~ item dans le frigo')
                            RageUI.Separator(' ')
                        end
                    end)
                    Wait(0)
                end
            end)
        end
    end
end


Keys.Register(BurgerShotConfig.BossMenu, "menuPatron", "Ouvrir le menu patron ", function ()
    UpdateJobPlayer()
    if value == '"burgershot"' then
        PlayerInBoss = true
        MenuPatron()
    end
end)



CreateThread(function ()
    local ped = GetHashKey('a_m_m_hillbilly_01')
    RequestModel(ped)
    while not HasModelLoaded(ped) do Wait(5) end
    local create = CreatePed(4, ped, BurgerShotConfig.Point.shopItems, 180.0, false, true)
    FreezeEntityPosition(create, true)
    SetEntityInvincible(create, true)

    while true do 
        local interval = 700
        local ped = PlayerPedId()
        local playerPosition = GetEntityCoords(ped)
        local dstCraftBurger = #(playerPosition - BurgerShotConfig.Point.CraftBurger)
        local dstCraftFrite = #(playerPosition - BurgerShotConfig.Point.CraftFrite)
        local dstFrigo = #(playerPosition - BurgerShotConfig.Point.clothePoint)
        local dstCar = #(playerPosition - BurgerShotConfig.Point.carPoint)
        local dstDeleteCar = #(playerPosition - BurgerShotConfig.Point.deleteCarSpawn)
        local dstShop = #(playerPosition - BurgerShotConfig.Point.shopItems)
        
        if dstCraftBurger >= 2.0 and dstCraftFrite >= 2.0 and dstFrigo >= 2.0 and dstCar >= 2.0 and dstDeleteCar >= 3.5 and dstShop >= 2.0  and PlayerInFoodTruck == false and PlayerInBoss == false then
            if menuOpen == true then
                RageUI.CloseAll()
                menuOpen = false
            end
        end

        if dstCraftBurger <= 5 or dstFrigo <= 5 or dstCar <= 2  then
            UpdateJobPlayer()
            interval = 0
            DrawMarker(23, BurgerShotConfig.Point.CraftBurger, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
            DrawMarker(23, BurgerShotConfig.Point.CraftFrite, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
            DrawMarker(23, BurgerShotConfig.Point.clothePoint, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
            DrawMarker(23, BurgerShotConfig.Point.carPoint, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
            DrawMarker(23, BurgerShotConfig.Point.deleteCarSpawn, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)

            if value == '"burgershot"'and dstCraftBurger <= 1.5 then
                interval = 0
                AddTextEntry("burger", "Appuyez sur ~INPUT_PICKUP~ pour utiliser le ~g~Grill")
                DisplayHelpTextThisFrame("burger", false)
                if IsControlJustPressed(0, 38) then
                    MenuBurgerShot('Burger')
                end
            end
            if value == '"burgershot"'and dstCraftFrite <= 1.5 then
                interval = 0
                AddTextEntry("frite", "Appuyez sur ~INPUT_PICKUP~ pour utiliser la ~g~Friteuse")
                DisplayHelpTextThisFrame("frite", false)
                if IsControlJustPressed(0, 38) then
                    MenuBurgerShot('Frite')
                end
            end
            if value == '"burgershot"'and dstFrigo <= 1.5 then
                interval = 0
                AddTextEntry("frigo", "Appuyez sur ~INPUT_PICKUP~ pour utiliser le ~g~Frigo")
                DisplayHelpTextThisFrame("frigo", false)
                if IsControlJustPressed(0, 38) then
                    MenuBurgerShot('Frigo')
                end
            end
            if value == '"burgershot"'and dstCar <= 1.5 then
                interval = 0
                AddTextEntry("car", "Appuyez sur ~INPUT_PICKUP~ pour acceder aux utilitaire")
                DisplayHelpTextThisFrame("car", false)
                if IsControlJustPressed(0, 38) then
                    MenuBurgerShot('car')
                end
            end
            
        end

        if dstShop <= 5 then
            interval = 0
            UpdateJobPlayer()
                if value == '"burgershot"'and dstShop <= 1.5 then
                    interval = 0
                    AddTextEntry("shopItem", "Appuyez sur ~INPUT_PICKUP~ pour acceder au ~g~magasin")
                    DisplayHelpTextThisFrame("shopItem", false)
                    if IsControlJustPressed(0, 38) then
                        MenuShopItem()
                    end
                end
        end
        
        if dstDeleteCar <= 5 then 
            UpdateJobPlayer()
            interval = 0
            DrawMarker(23, BurgerShotConfig.Point.deleteCarSpawn, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
            if value == '"burgershot"'and dstDeleteCar <= 1.5 then
                interval = 0
                AddTextEntry("car", "Appuyez sur ~INPUT_PICKUP~ pour rentrer le ~g~Food Truck")
                DisplayHelpTextThisFrame("car", false)
                if IsControlJustPressed(0, 38) then
                    MenuBurgerShot('deleteCar')
                end
            end
        end
        Wait(interval)
    end
end)

Citizen.CreateThread(function()
	local blip = AddBlipForCoord(-1189.6, -888.4, 14)
	SetBlipSprite (blip, 106)
	SetBlipDisplay(blip, 4)
	SetBlipScale  (blip, 1.0)
	SetBlipColour (blip, 6)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("BurgerShot")
	EndTextCommandSetBlipName(blip)
end)