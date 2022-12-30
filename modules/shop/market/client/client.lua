local menuOpen = false
local menuPanier = RageUI.CreateMenu("Panier", "Voici vos articles")

local Panier = {}
local totalPanier = 0


menuPanier.Closed = function ()
    menuOpen = false;
end

function PlayerActionPanier()
    ESX.TriggerServerCallback("getPlayerData", function(xPlayer) 
        playerData = xPlayer
    end)
end

len = function (table)
    local index = 0
    for k,v in pairs(table) do
        index = index +1
    end
    return index
end


openPanier = function(object, table)
    if object == 'Panier' then
        if menuOpen == false then
            menuOpen = true;
            menuPanier.Title = "Panier"
            RageUI.Visible(menuPanier, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(menuPanier, function()
                        if json.encode(Panier) ~= '[]' then
                            RageUI.Separator("↓ ~b~Panier~w~ ↓")
                            for k,v in pairs(Panier) do
                                RageUI.Button(k.." ("..v.amount..")", nil, {RightLabel = (v.amount*v.basicPrice).."~g~ $"}, true, {
                                    onSelected = function ()
                                        if Panier[k].amount <= 1 then
                                            Panier[k] = nil
                                        else
                                            Panier[k].amount = Panier[k].amount-1
                                        end 
                                    end
                                })
                            end
                            RageUI.Button("                       Vider le Panier", nil,{Color = {BackgroundColor={200,0,0,200}} },true, {
                                onSelected = function ()
                                    Panier = {}
                                    totalPanier = 0
                                end
                            })
                            totalPanier = 0
                            for k,v in pairs(Panier) do
                                totalPanier = totalPanier + (v.amount*v.basicPrice)
                            end
                            RageUI.Button("                         Payer : "..totalPanier.." $", nil, {Color = {BackgroundColor={0,200,0,200}}}, true, {
                                onSelected = function ()
                                    ESX.TriggerServerCallback("haveMoneyAndPay", function(haveMoney)

                                        if haveMoney then
                                            ESX.ShowNotification("Shop : \n Merci pour vos achats pour un total de "..totalPanier.." $", true, true, nil)
                                            Panier = {}
                                            totalPanier = 0
                                        else
                                            ESX.ShowNotification("Shop : \n Vous n'avez pas assez d'argent pour payer ", true, true, nil)
                                        end
                                    end, totalPanier, Panier)
                                    
                                end
                            })
                            
                        else
                            RageUI.Separator(" ")
                            RageUI.Separator("Votre panier est ~g~vide")
                            RageUI.Separator(" ")
                        end
                    end)
                    Wait(0)
                end
            end)
        end
    elseif object == 'Boisson' then
        if menuOpen == false then
            menuOpen = true;
            menuPanier.Title = "Boisson"
            RageUI.Visible(menuPanier, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(menuPanier, function() 
                        RageUI.Separator("↓ ~b~Boisson~w~ ↓")
                        for k,v in pairs(table) do
                            RageUI.Button(k, nil, {RightLabel = v.price.."~g~ $"}, true, {
                                onSelected = function()
                                        if not Panier[k] then
                                            Panier[k] = {
                                                price = v.price,
                                                amount = v.amount,
                                                basicPrice = v.price,
                                                db_name = v.name_db
                                            }
                                        else 
                                            if Panier[k].amount >= v.limitPurchase then
                                                Panier[k].amount = v.limitPurchase
                                            else
                                                Panier[k].price = Panier[k].price+v.price
                                                Panier[k].amount = Panier[k].amount+1
                                            end
                                        end
                                end,
                            })
                        end
                        RageUI.Separator("↓ ~g~Votre Panier~w~ ↓")
                        for k,v in pairs(Panier) do
                            RageUI.Button(k.." ("..v.amount..")", nil, {RightLabel = (v.amount*v.basicPrice).."~g~ $"}, true, {

                            })
                        end
                    end)
                    Wait(0)
                end
            end)
        end
    elseif object =='Chips' then
        if menuOpen == false then
            menuOpen = true;
            menuPanier.Title = "Chips"
            RageUI.Visible(menuPanier, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(menuPanier, function()
                        RageUI.Separator("↓ ~b~Chips~w~ ↓")
                        for k,v in pairs(table) do
                            RageUI.Button(k, nil, {RightLabel = v.price.."~g~ $"}, true, {
                                onSelected = function()
                                    if not Panier[k] then
                                        Panier[k] = {
                                            price = v.price,
                                            amount = v.amount,
                                            basicPrice = v.price,
                                            db_name = v.name_db
                                        }
                                    else
                                        if Panier[k].amount >= v.limitPurchase then
                                            Panier[k].amount = v.limitPurchase
                                        else
                                        Panier[k].price = Panier[k].price+v.price
                                        Panier[k].amount = Panier[k].amount+1
                                    end
                                end
                                end,
                            })
                        end
                        RageUI.Separator("↓ ~g~Votre Panier~w~ ↓")
                        for k,v in pairs(Panier) do
                            RageUI.Button(k.." ("..v.amount..")", nil, {RightLabel = (v.amount*v.basicPrice).."~g~ $"}, true, {

                            })
                        end
                    end)
                    Wait(0)
                end
            end)
        end
    elseif object == 'Nourriture' then
        if menuOpen == false then
            menuOpen = true;
            menuPanier.Title = "Nourriture"
            RageUI.Visible(menuPanier, true)
            CreateThread(function ()
                while menuOpen == true do
                    RageUI.IsVisible(menuPanier, function()
                        RageUI.Separator("↓ ~b~Nourriture~w~ ↓")
                        for k,v in pairs(table) do
                            RageUI.Button(k, nil, {RightLabel = v.price.."~g~ $"}, true, {
                                onSelected = function()
                                    if not Panier[k] then
                                        Panier[k] = {
                                            price = v.price,
                                            amount = v.amount,
                                            basicPrice = v.price,
                                            db_name = v.name_db
                                        }
                                    else
                                        if Panier[k].amount >= v.limitPurchase then
                                            Panier[k].amount = v.limitPurchase
                                        else
                                        Panier[k].price = Panier[k].price+v.price
                                        Panier[k].amount = Panier[k].amount+1
                                    end
                                end
                                end,
                            })
                        end
                        RageUI.Separator("↓ ~g~Votre Panier~w~ ↓")
                        for k,v in pairs(Panier) do
                            RageUI.Button(k.." ("..v.amount..")", nil, {RightLabel = (v.amount*v.basicPrice).."~g~ $"}, true, {

                            })
                        end
                    end)
                    Wait(0)
                end
            end)
        end
    end
end


CreateThread(function()
    while true do
        local interval = 700
        for i = 1 , #Config.Shop do
            local ped = PlayerPedId()
            local playerPosition = GetEntityCoords(ped)
            local dstPanier = #(playerPosition - Config.Shop[i].Position.Panier)
            local dstBoisson = #(playerPosition - Config.Shop[i].Position.Boisson)
            local dstChips = #(playerPosition - Config.Shop[i].Position.Chips)
            local dstNourriture = #(playerPosition - Config.Shop[i].Position.Nourriture)
            if (dstPanier >= 15.0) and (dstPanier <= 50) and menuOpen == true then
                Panier = {}
                totalPanier = 0
                menuOpen = false
                RageUI.CloseAll()
            end
                if dstPanier <= 15.0  then
                    interval = 0
                    DrawMarker(23, Config.Shop[i].Position.Panier, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
                    DrawMarker(23, Config.Shop[i].Position.Boisson, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
                    DrawMarker(23, Config.Shop[i].Position.Chips, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
                    DrawMarker(23, Config.Shop[i].Position.Nourriture, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, false, false, false, true)
                    if dstPanier <= 1.5 then
                        AddTextEntry("Panier", "Appuyez sur ~INPUT_PICKUP~ pour accerer au ~b~panier")
                        DisplayHelpTextThisFrame("Panier", false)
                        if IsControlJustPressed(0, 38) then
                            openPanier('Panier')
                        end
                    end
                end
                if dstBoisson <= 1.5 then
                    interval = 0
                    AddTextEntry("Boisson", "Appuyez sur ~INPUT_PICKUP~ pour accerer aux ~b~boissons")
                    DisplayHelpTextThisFrame("Boisson", false)
                    if IsControlJustPressed(0, 38) then
                        openPanier('Boisson', Config.Shop[i].Items.Boisson)
                    end
                end 
                if dstChips <= 1.5 then
                    interval = 0
                    AddTextEntry("Chips", "Appuyez sur ~INPUT_PICKUP~ pour accerer aux ~b~chips")
                    DisplayHelpTextThisFrame("Chips", false)
                    if IsControlJustPressed(0, 38) then
                        openPanier('Chips', Config.Shop[i].Items.Chips)
                    end
                end 
                if dstNourriture <= 1.5 then
                    interval = 0
                    AddTextEntry("Nourriture", "Appuyez sur ~INPUT_PICKUP~ pour accerer aux ~b~nourritures")
                    DisplayHelpTextThisFrame("Nourriture", false)
                    if IsControlJustPressed(0, 38) then
                        openPanier('Nourriture', Config.Shop[i].Items.Nourriture)
                    end
                end 
        end
        Wait(interval)
    end
end)

