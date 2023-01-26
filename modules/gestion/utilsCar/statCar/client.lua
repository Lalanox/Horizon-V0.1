local menuOpen = false
local AllCars = nil
local CarSelected = nil
local MainMenuGestionCar = RageUI.CreateMenu("Gestion véhicule", "Changer la propriété")
MainMenuGestionCar.Closed = function()
    menuOpen = false
end

local SubMenuGestionCar = RageUI.CreateSubMenu(MainMenuGestionCar, "Gestion véhicule", "Changer la propriété")

local GetPlayerCar = function()
    ESX.TriggerServerCallback('utilscar:GetPlayerCar', function(resultat)
        AllCars = resultat
    end)
end


GestionCarMenu = function()
    if menuOpen == false then
        menuOpen = true
        GetPlayerCar()
        while AllCars == nil do Wait(5) end
        RageUI.Visible(MainMenuGestionCar, true)
        CreateThread(function()
            while menuOpen == true do
                Wait(0)
                RageUI.IsVisible(MainMenuGestionCar, function()
                    RageUI.Separator("↓ ~b~Vos véhicules~s~ ↓")
                    if json.encode(AllCars) == '[]' then
                        RageUI.Separator()
                        RageUI.Separator("Vous n'avez pas de ~r~véhicule~s~")
                        RageUI.Separator()
                    else
                        for k,v in pairs(AllCars) do
                            RageUI.Button(v.NameCar..' - ~b~'..v.plate..' ~s~/ ~g~'..Horizon.StyleText(v.statu), nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    CarSelected = {
                                        name = v.NameCar,
                                        plate = v.plate,
                                        statu = v.statu
                                    }
                                end
                            }, SubMenuGestionCar)
                        end
                    end
                end)
                RageUI.IsVisible(SubMenuGestionCar, function()
                    if CarSelected ~= nil then
                        RageUI.Separator("↓ Véhicule : ~b~"..CarSelected.name.."~s~ - ~g~"..CarSelected.plate.."~s~ ↓")
                        RageUI.Separator("Statu : ~o~"..Horizon.StyleText(CarSelected.statu))
                        RageUI.Button('Passer le véhicule en Personnel', nil, {RightLabel = '→→'}, CarSelected.statu ~= 'personnel', {
                            onSelected = function()
                                TriggerServerEvent('utilscar:ChangeStatuCar', 'Perso' ,CarSelected.plate)
                                RageUI.CloseAll()
                                menuOpen = false
                            end
                        })
                        RageUI.Button('Passer le véhicule en Crew', nil, {RightLabel = '→→'}, CarSelected.statu ~= 'crew', {
                            onSelected = function()
                                TriggerServerEvent('utilscar:ChangeStatuCar', 'Crw' ,CarSelected.plate)
                                RageUI.CloseAll()
                                menuOpen = false
                            end
                        })
                        RageUI.Button('Passer le véhicule en Entreprise', nil, {RightLabel = '→→'}, CarSelected.statu ~= 'entreprise', {
                            onSelected = function()
                                TriggerServerEvent('utilscar:ChangeStatuCar', 'Entrp', CarSelected.plate)
                                RageUI.CloseAll()
                                menuOpen = false
                            end
                        })
                    end
                end)
            end
        end)
    end
end

Citizen.CreateThread(function()
    while true do 
        local interval = 700
        local ped = PlayerPedId()
        local playerPosition = GetEntityCoords(ped)
        local dstPlayerMairie = #(playerPosition - UtilsCar.PositionChangeStatuCar)

        if dstPlayerMairie <= 5 then
            interval = 0
            DrawMarker(23, UtilsCar.PositionChangeStatuCar, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
            if dstPlayerMairie <= 1.5 then
                AddTextEntry("Utils", "Appuyez sur ~INPUT_PICKUP~ pour parler à la ~b~personnes ")
                DisplayHelpTextThisFrame("Utils", false)
                if IsControlJustPressed(0, 38) then
                    GestionCarMenu()
                end
            end
        end
        Wait(interval)
    end
end)

