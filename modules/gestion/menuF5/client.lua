local PersonalMenu = RageUI.CreateMenu('', 'Gestion du Joueur')
local vehicleMain = RageUI.CreateSubMenu(PersonalMenu, '', 'Gestion véhicule');
local PartiAdministration = RageUI.CreateSubMenu(PersonalMenu, '', 'Gestion des Joueurs')
local admin_perso = RageUI.CreateSubMenu(PartiAdministration, '', 'Actions sur vous')
local admin_playerlist = RageUI.CreateSubMenu(PartiAdministration, '', 'Liste des Joueurs')
local admin_reportList = RageUI.CreateSubMenu(PartiAdministration, '', 'Liste des Reports')
local admin_selected_player = RageUI.CreateSubMenu(admin_playerlist, '', 'Joueur Selectionné')
local admin_playerInv = RageUI.CreateSubMenu(admin_selected_player, '', 'Inventaire')
local admin_playerWarn = RageUI.CreateSubMenu(admin_selected_player, '', 'Avertissement')
local admin_giveItemList = RageUI.CreateSubMenu(admin_selected_player, '', 'Liste des Items')
local menuOp = false
local AntiSpam = false
local group = nil
local allItems = nil
local listPlayers = nil
local reports = nil 
local PlayerSelected = nil
local warnsPlayerSelected = nil
local inventairePlayerSelected = nil
PersonalMenu.Closed = function()
    menuOp = false
end

local staff = false;
local noclip = false;
local invincible = false;
local invisible = false;
local nomsPlayer = false;
local blips = false;
local NoClipSpeed = 0.7;
local showAllOption = false;
local vehicleStopped = false;

local indexDoor = 1;
local Portes = {
    {Name = "Toutes"},
    {Name = "Avant Gauche", num = 0},
    {Name = "Avant Droite", num = 1},
    {Name = "Arrière Gauche", num = 2},
    {Name = "Arrière Droite", num = 3},
    {Name = "Capot", num = 4},
    {Name = "Coffre", num = 5}
}

local indexWindow = 1;
local Windows = {
    {Name = "Toutes"},
    {Name = "Avant Gauche", num = 0},
    {Name = "Avant Droite", num = 1},
    {Name = "Arrière Gauche", num = 2},
    {Name = "Arrière Droite", num = 3}
}

local function menuPerso()
    if menuOp == false then
        menuOp = true;
        ESX.TriggerServerCallback("Horizon-menuF5:getGroup", function(resultat)
            group = resultat;
            RageUI.Visible(PersonalMenu, true)
            CreateThread(function()
                while menuOp == true do
                    Wait(0)
                    RageUI.IsVisible(PersonalMenu, function()
                        RageUI.Button('Mes Informations', nil, {RightLabel = '→→'}, true, {})

                        RageUI.Button('Actions véhicule', nil, {RightLabel = '→→'}, IsPedInAnyVehicle(PlayerPedId(), false) and IsVehicleDriveable(GetVehiclePedIsIn(PlayerPedId(), false), true), {
                            onSelected = function()
                                local vehicleIn = GetVehiclePedIsIn(PlayerPedId(), false);
                                if not GetIsVehicleEngineRunning(vehicleIn) and vehicleStopped == false then
                                    vehicleStopped = true;
                                elseif GetIsVehicleEngineRunning(vehicleIn) and vehicleStopped == true then
                                    vehicleStopped = false;
                                end
                            end
                        }, vehicleMain);

                        RageUI.Button('Paramètres visuel', nil, {RightLabel = '→→'}, true, {})
                        RageUI.Button('Administration', nil, {RightLabel = '→→'}, group == 'moderateur' or group == 'administrateur' or group == 'superadmin' or group == 'fondateur'
                        , {}, PartiAdministration)
                    end)
                    RageUI.IsVisible(vehicleMain, function()
                        if IsPedInAnyVehicle(PlayerPedId(), false) and IsVehicleDriveable(GetVehiclePedIsIn(PlayerPedId(), false), true) then
                            local vehicleIn = GetVehiclePedIsIn(PlayerPedId(), false);

                            RageUI.Checkbox("Eteindre", "Eteindre le moteur du véhicule", vehicleStopped, {}, {
                                onChecked = function()
                                    SetVehicleEngineOn(vehicleIn, false, false, true);
                                    SetVehicleUndriveable(vehicleIn, true);
                                end,
                                onUnChecked = function()
                                    SetVehicleEngineOn(vehicleIn, true, false, true);
                                    SetVehicleUndriveable(vehicleIn, false);
                                end,
                                onSelected = function(i)
                                    vehicleStopped = i;
                                end
                            });

                            RageUI.List("Portes", Portes, indexDoor, "Ouvrir/Fermer les portières de votre véhicule", {}, true, {
                                onListChange = function(index, actual)
                                    if index ~= indexDoor then
                                        indexDoor = index;
                                    end
                                end,
                                onSelected = function(index, actual)
                                    if actual.Name:lower() == "toutes" then
                                        allDoorOpen = not allDoorOpen;
                                        if allDoorOpen then
                                            for i = 0, 7 do
                                                SetVehicleDoorOpen(vehicleIn, i, false, false);
                                            end
                                        else
                                            for i = 0, 5 do
                                                SetVehicleDoorShut(vehicleIn, i, false);
                                            end
                                        end
                                    else
                                        local numToStr = tostring(actual.num);
                                        if not DoorOpened then DoorOpened = {}; end
                                        DoorOpened[numToStr] = not DoorOpened[numToStr];
                                        if DoorOpened[numToStr] then
                                            SetVehicleDoorOpen(vehicleIn, actual.num, false, false);
                                        else
                                            SetVehicleDoorShut(vehicleIn, actual.num, false);
                                        end
                                    end
                                end
                            });

                            RageUI.List("Vitres", Windows, indexWindow, "Descendre/Monter les fenètres de votre véhicule", {}, true, {
                                onListChange = function(index, actual)
                                    if index ~= indexWindow then
                                        indexWindow = index;
                                    end
                                end,
                                onSelected = function(index, actual)
                                    if actual.Name:lower() == "toutes" then
                                        allWindowsOpen = not allWindowsOpen;
                                        if allWindowsOpen then
                                            RollDownWindows(vehicleIn);
                                        else
                                            for i = 0, 4 do
                                                RollUpWindow(vehicleIn, i);
                                            end
                                        end
                                    else
                                        local numToStr = tostring(actual.num);
                                        if not WindowOpened then WindowOpened = {}; end
                                        WindowOpened[numToStr] = not WindowOpened[numToStr];
                                        if WindowOpened[numToStr] then
                                            RollDownWindow(vehicleIn, actual.num);
                                        else
                                            RollUpWindow(vehicleIn, actual.num);
                                        end
                                    end
                                end
                            });
                        else
                            RageUI.GoBack();
                        end
                    end)
                    RageUI.IsVisible(PartiAdministration, function()
                        RageUI.Checkbox("Mode Administration", nil, staff, {}, {
                            onChecked = function()
                                showOption()
                                showAllOption = true
                                TriggerServerEvent('administartion:takeStaff', 'add')
                            end,
                            onUnChecked = function()
                                TriggerServerEvent('administartion:takeStaff', 'off')
                                staff = false
                                noclip = false
                                invincible = false
                                invisible = false
                                nomsPlayer = false
                                blips = false
                                showAllOption = false
                            end,
                            onSelected = function(i)
                                staff = i;
                            end
                        })
                        if staff == true then
                            RageUI.Separator('____________________')
                            RageUI.Button('Actions Personnelles', nil, {RightLabel = '→→'}, true, {}, admin_perso)
                            RageUI.Button('Liste des joueurs', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    ESX.TriggerServerCallback("administration:getListPlayer", function(resultat)
                                        listPlayers = resultat
                                    end)
                                end
                            }, admin_playerlist)
                            RageUI.Button('Reports', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    ESX.TriggerServerCallback("administration:getReports", function(resultat)
                                        reports = resultat
                                    end)
                                end
                            }, admin_reportList)
                        end
                    end)
                    RageUI.IsVisible(admin_reportList, function()
                        if reports ~= nil then
                            for k,v in pairs(reports) do
                                RageUI.Button('Report N°', nil, {}, true, {}, function()

                                end)
                            end
                        end
                    end)
                    RageUI.IsVisible(admin_playerlist, function()
                        if listPlayers ~= nil then
                            RageUI.Separator('Il y a ~b~' .. #listPlayers .. ' ~s~joueurs');

                            for k, v in pairs(listPlayers) do
                                if not v.groupColor and GlobalConfig.Admin.rankColour[v.group] then
                                    v.groupColor = GlobalConfig.Admin.rankColour[v.group];
                                end

                                if v.group == "user" then
                                    RageUI.Button('[~b~'..v.source..'~s~]  '..v.name, nil, {RightLabel = '→→'}, true, {
                                        onSelected = function() PlayerSelected = v; end
                                    }, admin_selected_player);
                                else
                                    RageUI.Button('[~b~'..v.source..'~s~]  '..v.name..' - ~' ..tostring(v.groupColor).. '~'..Horizon.StyleText(v.group)..'~s~', nil, {RightLabel = '→→'}, true, {
                                        onSelected = function() PlayerSelected = v; end
                                    }, admin_selected_player);
                                end
                            end
                        end
                    end)
                    RageUI.IsVisible(admin_selected_player, function()
                        if PlayerSelected ~= nil then 
                            RageUI.Separator('Nom : ~b~'..PlayerSelected.name..' ~s~[~b~'..PlayerSelected.source..'~s~]')
                            RageUI.Separator('ID unique : ~o~'..PlayerSelected.id_unique)
                            RageUI.Separator('Travail : ~g~'..PlayerSelected.job.label..' ~s~/~g~ '..PlayerSelected.job.grade_label)
                            RageUI.Separator('____________________')
                            RageUI.Button('Voir l\'inventaire ', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    inventairePlayerSelected = nil 
                                    ESX.TriggerServerCallback("administration:inventairePlayer", function(resultat)
                                        inventairePlayerSelected = resultat
                                    end, PlayerSelected.source)
                                end
                            }, admin_playerInv)

                            RageUI.Button('Voir les warns', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    warnsPlayerSelected = nil 
                                    ESX.TriggerServerCallback("administration:warnsPlayer", function(resultat)
                                        warnsPlayerSelected = resultat
                                    end, PlayerSelected.source)
                                end
                            }, admin_playerWarn)
                            RageUI.Button('Voir les bans', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()

                                end
                            })
                            RageUI.Button('Give un item', nil, {RightLabel = '→→'}, group == 'administrateur' or group == 'superadmin' or group == 'fondateur', {
                                onSelected = function()
                                    ESX.TriggerServerCallback("administration:getAllItems", function(resultat)
                                        allItems = resultat
                                    end)
                                end
                            }, admin_giveItemList)
                            RageUI.Button('Give de l\'argent', nil, {RightLabel = '→→'}, group == 'superadmin' or group == 'fondateur', {
                                onSelected = function()
                                    local moneyToGive = KeyboardInput("ADMIN_MONEY", "Montant à donner", "", 8)
                                    if Horizon.isInteger(moneyToGive) then
                                        if tonumber(moneyToGive) > 0 then
                                            TriggerServerEvent('administration:ActionAdmin', 'giveMoney', PlayerSelected.source, tonumber(moneyToGive))
                                        else
                                            ESX.ShowNotification('~r~Administration ~s~\nVous devez rentrer un nombre correct')
                                        end
                                    else
                                        ESX.ShowNotification('~r~Administration ~s~\nVous devez rentrer un nombre correct')
                                    end
                                end
                            })
                            RageUI.Button('Se téléporter sur le joueur', nil, {RightLabel = '→'}, true, {
                                onSelected = function()
                                    TriggerServerEvent('administration:ActionAdmin', 'goto', PlayerSelected.source)
                                end
                            })
                            RageUI.Button('Téléporter le joueur sur moi', nil, {RightLabel = '→'}, true, {
                                onSelected = function()
                                    TriggerServerEvent('administration:ActionAdmin', 'bring', PlayerSelected.source)
                                end
                            })
                            RageUI.Button('Mettre un warn', nil, {RightLabel = '→'}, true, {
                                onSelected = function()
                                    local messToWarn = KeyboardInput("ADMIN_MESS", "Entré la raison du warn de "..PlayerSelected.name, "", 10)
                                    TriggerServerEvent('administration:ActionAdmin', 'addWarn', PlayerSelected.source, messToWarn)
                                end
                            })
                            RageUI.Button('Envoyer un message', nil, {RightLabel = '→'}, true, {
                                onSelected = function()
                                    local messToPlay = KeyboardInput("ADMIN_MESS", "Envoyée un message a "..PlayerSelected.name, "", 50)
                                    TriggerServerEvent('administration:ActionAdmin', 'message', PlayerSelected.source, messToPlay)
                                end
                            })
                            RageUI.Button('Expulser le joueur', nil, {RightLabel = '→'}, true, {
                                onSelected = function()
                                    local messKick = KeyboardInput("ADMIN_KICK", "Entrée la raison du kick "..PlayerSelected.name, "", 20)
                                    TriggerServerEvent('administration:ActionAdmin', 'kick', PlayerSelected.source, messKick)
                                end
                            })
                            RageUI.Button('Wype le joueur (à faire)', nil, {RightLabel = '→', Color = {BackgroundColor={236,74,74,200}}}, true, {
                                
                            })
                            RageUI.Button('Bannir le joueur (à faire)', nil, {RightLabel = '→', Color = {BackgroundColor={236,74,74,200}}}, true, {
                                onSelected = function()
                                    local validBan = KeyboardInput("ADMIN_BAN", "Ete vous sur de vouloir bannir (oui/non) "..PlayerSelected.name, "", 20)
                                    if validBan == 'oui' then
                                        local reasonBan = KeyboardInput("ADMIN_BAN", "Entrée la raison du ban "..PlayerSelected.name, "", 20)
                                        local timeBan = KeyboardInput("ADMIN_BAN", "Entrée la durée du bannissement  "..PlayerSelected.name, "", 20)
                                        TriggerServerEvent('banSysteme:ban', PlayerSelected.source, reasonBan, timeBan)
                                    else
                                        ESX.ShowNotification('~r~Administration ~s~\nVous avez annulé le ban')
                                    end
                                end
                            })
                        end
                    end)
                    RageUI.IsVisible(admin_playerInv, function()
                        if inventairePlayerSelected ~= nil then
                            if json.encode(inventairePlayerSelected) == '[]' then
                                RageUI.Separator('Inventaire vide')
                                RageUI.Button('Revenir en arrière', nil, {RightLabel = '→→'}, true, {
                                    onSelected = function()
                                        RageUI.GoBack()
                                    end
                                })
                            else
                                for k, v in pairs(inventairePlayerSelected) do
                                    RageUI.Button('[~b~'..v..'~s~] '..Horizon.StyleText(k), nil, {RightLabel = '→→'}, true, {})
                                end
                            end
                        end
                    end)
                    RageUI.IsVisible(admin_giveItemList, function()
                        if allItems ~= nil then
                            RageUI.Button('Recherche manuel', nil , {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    local itemToGive = KeyboardInput("ADMIN_ITEM", "Entré le nom de l'item", "", 10)
                                    local quantityToGive = KeyboardInput("ADMIN_QUANTITY", "Entré la quantité de l'item", "", 10)
                                    if itemToGive ~= nil then
                                        if Horizon.isInteger(quantityToGive) then
                                            TriggerServerEvent('administration:ActionAdmin', 'giveItem', PlayerSelected.source, itemToGive, quantityToGive)
                                        else
                                            ESX.ShowNotification('~r~Admininstration ~s~\nLa quantité doit être un nombre entier')
                                        end
                                    end
                                end
                            })
                            RageUI.Separator('____________________')
                            if json.encode(allItems) == '[]' then
                                RageUI.Separator('Aucun item')
                                RageUI.Button('Revenir en arrière', nil, {RightLabel = '→→'}, true, {
                                    onSelected = function()
                                        RageUI.GoBack()
                                    end
                                })
                            else
                                for k, v in pairs(allItems) do
                                    RageUI.Button(Horizon.StyleText(k), nil, {RightLabel = '→→'}, true, {
                                        onSelected = function()
                                            local quantityToGive = KeyboardInput("ADMIN_QUANTITY", "Entré la quantité de l'item", "", 10)
                                            if quantityToGive ~= nil then
                                                if Horizon.isInteger(quantityToGive) then
                                                    TriggerServerEvent('administration:ActionAdmin', 'giveItem', PlayerSelected.source, k, quantityToGive)
                                                else
                                                    ESX.ShowNotification('~r~Admininstration ~s~\nLa quantité doit être un nombre entier')
                                                end
                                            end
                                        end
                                    })
                                end
                            end
                        end
                    end)
                    RageUI.IsVisible(admin_playerWarn, function()
                        if warnsPlayerSelected ~= nil then
                            if #warnsPlayerSelected == 0 then
                                RageUI.Separator('Ce joueur n\'a pas de warns')
                                RageUI.Button('Revenir en arrière', nil, {RightLabel = '→→'}, true, {
                                    onSelected = function()
                                        RageUI.GoBack()
                                    end
                                })
                            else
                                RageUI.Separator('Ce joueur a ~r~'..#warnsPlayerSelected..' ~s~warns')
                                for k,v in pairs(warnsPlayerSelected) do
                                    RageUI.Button('Warns ID : '..v.id, 'Raison : ~b~'..v.raison..'\n~s~Auteur : ~b~'..v.auteur..'\n~s~Date : ~b~'..v.date, {RightLabel = '~r~Supprimé'}, true, {
                                        onSelected = function()
                                            TriggerServerEvent('administration:ActionAdmin', 'delWarn', nil, nil, v.id)
                                            RageUI.GoBack()
                                        end
                                    })
                                end
                            end
                        end
                    end)
                    RageUI.IsVisible(admin_perso, function()
                        RageUI.Checkbox("Noclip", nil, noclip, {Style = RageUI.CheckboxStyle.Tick}, {
                            onChecked = function()
                                NoClip(true)
                            end,
                            onUnChecked = function()
                                NoClip(false)
                                invincible = false
                                invisible = false
                            end,
                            onSelected = function(i)
                                noclip = i;
                            end
                        })
                        RageUI.Checkbox("Invincible", nil, invincible, {Style = RageUI.CheckboxStyle.Tick}, {
                            onChecked = function()
                                SetEntityInvincible(PlayerPedId(), true)
                                showAllOption = true
                                showOption()
                            end,
                            onUnChecked = function()
                                SetEntityInvincible(PlayerPedId(), false)
                                showOption()
                            end,
                            onSelected = function(i)
                                invincible = i;
                            end
                        })
                        RageUI.Checkbox("Invisible", nil, invisible, {Style = RageUI.CheckboxStyle.Tick}, {
                            onChecked = function()
                                SetEntityVisible(PlayerPedId(), 0, 0)
                                showAllOption = true
                                showOption()
                            end,
                            onUnChecked = function()
                                SetEntityVisible(PlayerPedId(), 1, 0)
                                showOption()
                            end,
                            onSelected = function(i)
                                invisible = i;
                            end
                        })
                        RageUI.Checkbox("Aficher les noms", nil, nomsPlayer, {Style = RageUI.CheckboxStyle.Tick}, {
                            onChecked = function()
                                nomsPlayer = true
                            end,
                            onUnChecked = function()
                                nomsPlayer = false
                            end,
                            onSelected = function(i)
                                nomsPlayer = i;
                            end
                        })
                        RageUI.Checkbox("Aficher les blips", nil, blips, {Style = RageUI.CheckboxStyle.Tick}, {
                            onChecked = function()
                                blips = true
                            end,
                            onUnChecked = function()
                                blips = false
                            end,
                            onSelected = function(i)
                                blips = i;
                            end
                        })
                    end)
                end
            end)
        end)
    end
end


Keys.Register('F5', 'menuPerso', 'Menu Personnel', function()
    CreateThread(function()
        if AntiSpam == false then
            AntiSpam = true
            menuPerso()
            SetTimeout(1000, function()
                AntiSpam = false
            end)
        end
    end)
end)

RegisterCommand('report', function(source, args, rawCommand)
    print('Test', args)
    if source ~= 0 then
        TriggerServerEvent('administration:report', args)
    end
end, false)


RegisterNetEvent('administration:notifStaff')
AddEventHandler('administration:notifStaff', function(joueur, statu)
    if staff == true then
        if statu == 'on' then
            ESX.ShowNotification('~r~Administration ~s~\n~b~'..joueur..' ~s~a pris sont service', true, true)
        elseif statu == 'off' then
            ESX.ShowNotification('~r~Administration ~s~\n~b~'..joueur..' ~s~a quitter sont service', true, true)
        end
    end
end)


function getCamDirection()
    local heading = GetGameplayCamRelativeHeading() + GetEntityHeading(PlayerPedId())
    local pitch = GetGameplayCamRelativePitch()
    local coords = vector3(-math.sin(heading * math.pi / 180.0), math.cos(heading * math.pi / 180.0), math.sin(pitch * math.pi / 180.0))
    local len = math.sqrt((coords.x * coords.x) + (coords.y * coords.y) + (coords.z * coords.z))

    if len ~= 0 then
        coords = coords / len
    end

    return coords
end 

function showOption()
    CreateThread(function()
        while showAllOption do
            Wait(0)
            if invincible == true and invisible == false and noclip == false then
                Visual.Subtitle("~g~ Invincible~s~", 1) 
            elseif invincible == false and invisible == true and noclip == false then
                Visual.Subtitle("~g~ Invisible~s~", 1)
            elseif invincible == true and invisible == true and noclip == false then
                Visual.Subtitle("~g~ Invincible~s~ - ~g~Invisible~s~", 1)
            elseif noclip == true then
                Visual.Subtitle("~g~ Invincible~s~ - ~g~Invisible~s~", 1)
            elseif staff == true then
                Visual.Subtitle("~r~Administration - "..Horizon.StyleText(group), 1)
            end
            if invincible == false and invisible == false and noclip == false and staff == false or staff == false then 
                showAllOption = false
            end
        end 
    end)
end

function NoClip(bool)
    noclip = bool
    if noclip then
        showOption()
        showAllOption = true
        SetEntityInvincible(PlayerPedId(), true)
        CreateThread(function()
            while noclip do
                Wait(1)
                local pCoords = GetEntityCoords(PlayerPedId(), false)
                local camCoords = getCamDirection()
                SetEntityVelocity(PlayerPedId(), 0.01, 0.01, 0.01)
                SetEntityCollision(PlayerPedId(), 0, 1)
                FreezeEntityPosition(PlayerPedId(), true)

                if IsControlPressed(0, 32) then
                    pCoords = pCoords + (NoClipSpeed * camCoords)
                end

                if IsControlPressed(0, 269) then
                    pCoords = pCoords - (NoClipSpeed * camCoords)
                end

                if IsDisabledControlJustPressed(1, 15) then
                    NoClipSpeed = NoClipSpeed + 0.3
                end
                if IsDisabledControlJustPressed(1, 14) then
                    NoClipSpeed = NoClipSpeed - 0.3
                    if NoClipSpeed < 0 then
                        NoClipSpeed = 0
                    end
                end
                SetEntityCoordsNoOffset(PlayerPedId(), pCoords, true, true, true)
                SetEntityVisible(PlayerPedId(), 0, 0)
            end
            FreezeEntityPosition(PlayerPedId(), false)
            SetEntityVisible(PlayerPedId(), 1, 0)
            SetEntityCollision(PlayerPedId(), 1, 1)
            SetEntityInvincible(PlayerPedId(), false)
        end)
        CreateThread(function()
            while noclip do
                if IsControlPressed(0, 21) then
                    NoClipSpeed = 2.5
                else
                    NoClipSpeed = 0.5
                end
                Wait(1)
            end
        end)
    end
end