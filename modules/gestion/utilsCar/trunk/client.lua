local AntiSpam = true
local menuOpen = false
local Limit = nil
local limitCar = 0
local CarInventory = nil

local MenuTrunk = RageUI.CreateMenu('Coffre', "Inventaire du coffre")
MenuTrunk.Closed = function()
    menuOpen = false
    local closetCar = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 127)
    SetVehicleDoorShut(closetCar, 5, false)
end


local AddInTrunk = RageUI.CreateSubMenu(MenuTrunk, 'Coffre', "Votre inventaire")


local Trunk = function(plate)
    if menuOpen == false then
        menuOpen = true
        ESX.TriggerServerCallback("trunk:GetLimitkCar", function(invt, resultat)
            CarInventory = invt
            Limit = resultat
        end, plate)
        while Limit == nil and CarInventory == nil do Wait(5) end
        RageUI.Visible(MenuTrunk, true)
        CreateThread(function()
            while menuOpen == true do
                Wait(0)
                RageUI.IsVisible(MenuTrunk, function()
                    if json.encode(Limit) ~= '[]' then
                        RageUI.Button('Déposer des objets', nil, {RightLabel = '→→'}, true, {}, AddInTrunk)
                        for k,v in pairs(TrunkConf) do
                            if k == Limit[1].spawnNameCar then
                                limitCar = v
                                break
                            end
                        end
                        -- print(json.encode(Limit))
                        if Limit[1].inventory == 'vide' then
                            RageUI.Separator(" Nombre d'objet : ~b~0 ~s~/ ~b~"..limitCar)
                            RageUI.Separator()
                            RageUI.Separator("Le coffre du véhicule est ~r~vide")
                            RageUI.Separator()
                        else
                            for k,v in pairs(json.decode(CarInventory[1].inventory)) do
                                print(k)
                            end
                        end
                    else
                        RageUI.Separator()
                        RageUI.Separator("Ce véhicule ne dispose pas de coffre")
                        RageUI.Separator()
                    end
                end)
                RageUI.IsVisible(AddInTrunk, function()
                    for k,v in pairs(ESX.GetPlayerData().inventory) do
                        if v.count > 0 then
                            RageUI.Button(v.label..' (~b~'..v.count..'~s~)', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    local AddItemsInTrunk = KeyboardInput("ADDITEM_TRUNK","Déposer", "", 4)
                                    if tonumber(AddItemsInTrunk) and tonumber(AddItemsInTrunk) < tonumber(limitCar) then
                                        print('passer')
                                        TriggerServerEvent('trunk:AddNewItem', v.label ,AddItemsInTrunk, plate)
                                        RageUI.CloseAll()
                                        menuOpen = false
                                    else
                                        ESX.ShowNotification("~r~Voiture ~s~\nVous ne pouvez pas déposer cette quantité dans le coffre", true, true, nil)
                                    end
                                end
                            })
                        end
                    end
                end)
            end
        end)
    end
end

Keys.Register("K", "openTrunk", "Ouvrir le coffre du véhicule", function()    
    if AntiSpam == true then
        local closetCar = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 127)
        local plate = GetVehicleNumberPlateText(closetCar)
        local LockStatu = GetVehicleDoorLockStatus(closetCar)
        if plate ~= nil then
            if LockStatu == 1 then
                if menuOpen ~= true then
                    SetVehicleDoorOpen(closetCar, 5, false, false)
                    Trunk(plate)
                else
                    ESX.ShowNotification("~r~Voiture ~s~\nVous regarder déjà dans le coffre", true, true, nil)
                end
            elseif LockStatu == 2 then
                ESX.ShowNotification("~r~Voiture ~s~\nLe coffre de la voiture est fermer", true, true, nil)
            end 
            AntiSpam = false
            SetTimeout(2000, function()
                AntiSpam = true
            end)
        else
            ESX.ShowNotification("~r~Voiture ~s~\nAucune voiture autour de vous", true, true, nil)
        end
        while menuOpen == true do
            Wait(200)
            local closetCar = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 3.0, 0, 127)
            if closetCar == 0 then
                local newClose = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 127)
                SetVehicleDoorShut(newClose, 5, false)
                RageUI.CloseAll()
                menuOpen = false
            end
        end
    end   
end)