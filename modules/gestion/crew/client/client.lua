local menuOpenCrew = false
local totalOfRank = 0
local totalOfMembers = 0
local gradeSelect = nil
local Checked = false
local Checked2 = false
local Checked3 = false
local accesCompte = false
local accesGestion = false
local accesVehicle = false
local playerSelected = {}
local playerAround = {}
local indexPlayer = 1


local menuCrew = RageUI.CreateMenu("CREW", 'Systeme de crew')
menuCrew.Closed = function()
    menuOpenCrew = false
end 

local CreateCrew = RageUI.CreateSubMenu(menuCrew, 'CREW', 'Systeme de crew')
local crewGestionRank = RageUI.CreateSubMenu(menuCrew, 'CREW', 'Systeme de crew')
local CreateNewRank = RageUI.CreateSubMenu(menuCrew, 'CREW', 'Systeme de crew')
local GestionRankCrew = RageUI.CreateSubMenu(crewGestionRank, 'CREW', 'Systeme de crew')
local ModifGestionRankCrew = RageUI.CreateSubMenu(GestionRankCrew, 'CREW', 'Systeme de crew')
local MembersList = RageUI.CreateSubMenu(menuCrew, 'CREW', 'Systeme de crew')
local MembersListReduit = RageUI.CreateSubMenu(menuCrew, 'CREW', 'Systeme de crew')
local ModifMembersList = RageUI.CreateSubMenu(MembersList, 'CREW', 'Systeme de crew')



local GetCrew = function()
    ESX.TriggerServerCallback('crew:GetRankCrew',function(resultat, resultat2)
        crew = resultat
        crewPerm = resultat2
    end)
end

local GetOwnerCrew = function(crewName)
    ESX.TriggerServerCallback('crew:GetCrewOwner',function(resultat)
        crewOwner = resultat
    end, crewName)
end

local allRankOfCrew = function(name)
    ESX.TriggerServerCallback('crew:GetAllRankCrew',function(resultat)
        ranksCrew = resultat
    end, name)
end

local GetPermissionOfRank = function(nameCrw ,Wrank)
    ESX.TriggerServerCallback('crew:GetPermissionOfRank',function(resultat)
        permRank = resultat
    end, nameCrw, Wrank)
end

local GetAllMembreOfCrew = function(crew)
    ESX.TriggerServerCallback('crew:GetAllMembreOfCrew',function(resultat, resultat2)
        allMembres = resultat
        playerName = resultat2
    end, crew)
end

local KeyboardInput = function(title, TextEntry, ExampleText, MaxStringLenght)
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

RegisterCommand("crew", function()
    if menuOpenCrew == false then
        menuOpenCrew = true
        GetCrew()
        while crew == nil and crewPerm == nil do Wait(5) end
        if json.encode(crew) ~= '[[]]' then
            GetOwnerCrew(crew[1].crew_name)
        end
        RageUI.Visible(menuCrew, true)
        CreateThread(function()
            while menuOpenCrew == true do
                Wait(0)
                RageUI.IsVisible(menuCrew, function()
                    if json.encode(crew) == '[[]]' then
                        RageUI.Separator(" ↓ Vous n'avez aucun ~b~crew ~s~↓")
                        RageUI.Button('Créé un crew', nil, {RightLabel = '→→'}, true, {

                        }, CreateCrew)
                    else
                        RageUI.Separator(" ↓ Votre crew : ~b~"..crew[1].crew_name.." ~s~↓")
                        RageUI.Separator("Grade : ~g~"..crew[1].crew_grade)
                        if crewOwner == true then
                            RageUI.Button('Gerer les grades du crew', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    allRankOfCrew(crew[1].crew_name)
                                end
                            }, crewGestionRank)
                            local playerAround = ESX.Game.GetPlayersInArea(GetEntityCoords(PlayerPedId()), 20)
                            RageUI.Button('Recruter la personne', nil, {RightLabel = '→→'}, #playerAround > 0, {
                                onActive = function()
                                    Visual.Subtitle("<C>Appuyer sur [~b~Fleche G~s~] / [~b~Fleche D~s~] pour sélectionner la personne</C>", 1)
                                    if IsControlJustPressed(1, 175) and indexPlayer < #playerAround then
                                        indexPlayer = indexPlayer+1
                                    end
                                    if IsControlJustPressed(1, 174) and indexPlayer > 1 then
                                        indexPlayer = indexPlayer-1
                                    end
                                    local coordsPlayerSelecteded = GetEntityCoords(GetPlayerPed(playerAround[indexPlayer]))
                                    DrawMarker(20, coordsPlayerSelecteded.x,coordsPlayerSelecteded.y,coordsPlayerSelecteded.z+1.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0, 255, 0, 1, 2, 1, nil, nil, 0);
                                end,
                                onSelected = function()
                                    print(GetPlayerServerId(playerAround[indexPlayer]))


                                    
                                end
                            })
                            RageUI.Button('Virer la personne', nil, {RightLabel = '→→'}, #playerAround > 0, {
                                onActive = function()
                                    Visual.Subtitle("<C>Appuyer sur [~b~Fleche G~s~] / [~b~Fleche D~s~] pour sélectionner la personne</C>", 1)
                                    if IsControlJustPressed(1, 175) and indexPlayer < #playerAround then
                                        indexPlayer = indexPlayer+1
                                    end
                                    if IsControlJustPressed(1, 174) and indexPlayer > 1 then
                                        indexPlayer = indexPlayer-1
                                    end
                                    local coordsPlayerSelecteded = GetEntityCoords(GetPlayerPed(playerAround[indexPlayer]))
                                    DrawMarker(20, coordsPlayerSelecteded.x,coordsPlayerSelecteded.y,coordsPlayerSelecteded.z+1.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 255, 0, 0, 255, 0, 1, 2, 1, nil, nil, 0);
                                end,
                                onSelected = function()
                                    print(GetPlayerServerId(playerAround[indexPlayer]))



                                end
                            })
                            RageUI.Button('Liste des membres', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    GetAllMembreOfCrew(crew[1].crew_name)
                                end
                            }, MembersList)
                            RageUI.Button('Supprimer le crew', nil, {RightLabel= '→→', Color = {BackgroundColor={236,74,74,200}}}, true, {
                                onSelected = function()
                                    local SupprCrew = KeyboardInput("SUPP_CREWW", "Voulez vous vraiment supprimé le crew (oui/non)", "", 10)
                                    if SupprCrew == 'oui' then
                                        TriggerServerEvent('crew:DeleteCrew', crew[1].crew_name)
                                        RageUI.CloseAll()
                                        menuOpenCrew = false
                                    end
                                end
                            })
                        elseif crewPerm[1].permission_gestion == true then
                            RageUI.Button('Recruter la personne', nil, {RightLabel = '→→'}, true, {})
                            RageUI.Button('Gerer les grades du crew', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    allRankOfCrew(crew[1].crew_name)
                                end
                            }, crewGestionRank)
                            RageUI.Button('Liste des membres', nil, {RightLabel = '→→'}, true, {
                                onSelected = function()
                                    GetAllMembreOfCrew(crew[1].crew_name)
                                end
                            }, MembersListReduit)
                            RageUI.Button('Quitter le crew', nil, {RightLabel= '→→', Color = {BackgroundColor={236,74,74,200}}}, true, {
                                onSelected = function()
                                    local ExitCrew = KeyboardInput("EXIT_CREWW", "Voulez vous vraiment quitter le crew (oui/non)", "", 10)
                                    if ExitCrew == 'oui' then
                                        TriggerServerEvent('crew:ExitCrew', crew[1].crew_name) 
                                        RageUI.CloseAll()
                                        menuOpenCrew = false
                                    end
                                end
                            })
                        else
                            RageUI.Separator()
                            RageUI.Separator("Vous n'avez pas ~r~la permission")
                            RageUI.Separator("~s~de gérer le crew")
                            RageUI.Separator()
                            RageUI.Button('Quitter le crew', nil, {RightLabel= '→→', Color = {BackgroundColor={236,74,74,200}}}, true, {
                                onSelected = function()
                                    local ExitCrew = KeyboardInput("EXIT_CREWW", "Voulez vous vraiment quitter le crew (oui/non)", "", 10)
                                    if ExitCrew == 'oui' then
                                        TriggerServerEvent('crew:ExitCrew', crew[1].crew_name) 
                                        RageUI.CloseAll()
                                        menuOpenCrew = false
                                    end
                                end
                            })
                        end
                    end
                end)
                ---- Dans le crew
                RageUI.IsVisible(crewGestionRank, function()
                    RageUI.Separator('↓ Nombres de grades : ~b~'..totalOfRank..' ~s~/~b~ '..CREW.limitOfRanks..' ~s~↓')
                    while ranksCrew == nil do Wait(5) end
                    for k,v in pairs(ranksCrew) do 
                        totalOfRank = k
                        RageUI.Button("Grade : ~b~"..v.grade, nil, {RightLabel = '→→'}, v.grade ~= crew[1].crew_grade, {
                            onSelected = function()
                                gradeSelect = v.grade
                                GetPermissionOfRank(crew[1].crew_name , gradeSelect)
                            end
                        },GestionRankCrew)
                    end
                    if tonumber(totalOfRank) < tonumber(CREW.limitOfRanks) then
                        RageUI.Button('Créé un nouveau grade', nil, {RightLabel= '→→', Color = {BackgroundColor={110,228,137,200}}}, true, {}, CreateNewRank)
                    end
                end)
                RageUI.IsVisible(MembersList, function()
                    while allMembres == nil do Wait(5) end
                    RageUI.Separator('↓ Il y a ~b~'..totalOfMembers..' ~s~personnes dans le crew ↓')
                    for k,v in pairs(allMembres) do
                        totalOfMembers = k
                        RageUI.Button(v.firstname..' '..v.lastname..' - '..'[~b~'..v.crew_grade..'~s~]' , nil, {RightLabel= '→→'}, playerName ~= v.firstname..' '..v.lastname , {
                            onSelected = function()
                                playerSelected = {
                                    id = v.identifier,
                                    firstname = v.firstname,
                                    lastname = v.lastname,
                                    grade = v.crew_grade,
                                }
                            end
                        }, ModifMembersList)
                    end
                end)
                RageUI.IsVisible(MembersListReduit, function()
                    while allMembres == nil do Wait(5) end
                    RageUI.Separator('↓ Il y a ~b~'..totalOfMembers..' ~s~personnes dans le crew ↓')
                    for k,v in pairs(allMembres) do
                        totalOfMembers = k
                        RageUI.Button(v.firstname..' '..v.lastname..' - '..'[~b~'..v.crew_grade..'~s~]' , nil, {RightLabel= '→→'}, playerName ~= v.firstname..' '..v.lastname , {
                            onSelected = function()
                                playerSelected = {
                                    id = v.identifier,
                                    firstname = v.firstname,
                                    lastname = v.lastname,
                                    grade = v.crew_grade,
                                }
                            end
                        })
                    end
                end)
                RageUI.IsVisible(ModifMembersList, function()
                    while json.encode(playerSelected) == '[]' do Wait(5) end
                    RageUI.Separator('Personne : ~b~'..playerSelected.firstname..' '..playerSelected.lastname)
                    RageUI.Separator('Grade : ~g~'..playerSelected.grade)
                    RageUI.Button('Changer de grade', nil, {RightLabel= '→→'}, true, {
                        onSelected = function()
                            local gradeChange = KeyboardInput("CHANG_CREW", "Nom du grade", "", 20)
                            TriggerServerEvent('crew:ChangeRank', crew[1].crew_name, gradeChange, playerSelected.id, playerSelected.firstname, playerSelected.lastname)
                        end
                    },menuCrew)
                    RageUI.Button('Exclure '..playerSelected.firstname..' '..playerSelected.lastname..' du crew', nil, {RightLabel= '→→', Color = {BackgroundColor={236,74,74,200}}}, true, {
                        onSelected = function()
                            local validSupprCrew = KeyboardInput("SUPP_RANK", "Voulez vous vraiment supprimé le grade (oui/non)", "", 10)
                            if validSupprCrew == 'oui' then
                                TriggerServerEvent('crew:KickPlayerCrew', playerSelected.id, playerSelected.firstname, playerSelected.lastname)
                            end
                        end
                    },menuCrew)
                end) 
                RageUI.IsVisible(CreateNewRank, function()
                    RageUI.Button('Nom du grade :', nil, {RightLabel = fullNewgrade}, true, {
                        onSelected = function()
                            Newgrade = KeyboardInput('CREW_NEWGRADE', "Veuillez entrer le grade ", "", 20)  
                            str_Newgrade = Newgrade:gsub("%s", "")
                            str_Newgrade = string.gsub(str_Newgrade, "%s", "")
                            str_Newgrade = string.gsub(str_Newgrade, "%p", "")
                            fullNewgrade = '~b~'..tostring(str_Newgrade)
                        end
                    })
                    RageUI.Separator('↓ Permission ↓')
                    RageUI.Checkbox("Accès Compte partager", nil, Checked, {Style = RageUI.CheckboxStyle.Tick}, {
                        onChecked = function()
                            accesCompte = true
                        end,
                        onUnChecked = function()
                            accesCompte = false
                        end,
                        onSelected = function(i)
                            Checked = i;
                        end
                    })
                    RageUI.Checkbox("Accès Gestion du crew", nil, Checked2, {Style = RageUI.CheckboxStyle.Tick}, {
                        onChecked = function()
                            accesGestion = true
                        end,
                        onUnChecked = function()
                            accesGestion = false
                        end,
                        onSelected = function(i)
                            Checked2 = i;
                        end
                    })
                    RageUI.Checkbox("Accès Véhicule partager", nil, Checked3, {Style = RageUI.CheckboxStyle.Tick}, {
                        onChecked = function()
                            accesVehicle = true
                        end,
                        onUnChecked = function()
                            accesVehicle = false
                        end,
                        onSelected = function(i)
                            Checked3 = i;
                        end
                    })
                    RageUI.Separator('↓ Validation ↓')
                    RageUI.Button('Créé le grade', nil, {RightLabel= '→→', Color = {BackgroundColor={110,228,137,200}}}, true, {
                        onSelected = function()
                            if Newgrade ~= nil then
                                print(' 1 --> ', accesCompte)
                                print(' 2 --> ', accesGestion)
                                print(' 3 --> ', accesVehicle)
                                TriggerServerEvent('crew:CreateNewRank', crew[1].crew_name, str_Newgrade, accesCompte, accesGestion, accesVehicle)
                                RageUI.GoBack()
                                RageUI.GoBack()
                            else
                                ESX.ShowNotification("~r~Crew création\n~s~Veuillez mettre un nom pour le ~b~grade~s~", true, true)
                            end
                        end
                    })
                end)

                RageUI.IsVisible(GestionRankCrew, function()
                    while gradeSelect == nil do Wait(5) end
                    while permRank == nil do Wait(5) end
                    RageUI.Separator('↓ Autorisations de ~b~'..gradeSelect..' ~s~↓')
                    RageUI.Checkbox("Accès Compte partager", nil, permRank[1].permision_bank, {Style = RageUI.CheckboxStyle.Tick}, {
                        onChecked = function()
                            accesCompte = true
                        end,
                        onUnChecked = function()
                            accesCompte = false
                        end,
                        onSelected = function(i)
                            Checked = i;
                        end
                    })
                    RageUI.Checkbox("Accès Gestion du crew", nil, permRank[1].permission_gestion, {Style = RageUI.CheckboxStyle.Tick}, {
                        onChecked = function()
                            accesGestion = true
                        end,
                        onUnChecked = function()
                            accesGestion = false
                        end,
                        onSelected = function(i)
                            Checked2 = i;
                        end
                    })
                    RageUI.Checkbox("Accès Véhicule partager", nil, permRank[1].permision_car, {Style = RageUI.CheckboxStyle.Tick}, {
                        onChecked = function()
                            accesVehicle = true
                        end,
                        onUnChecked = function()
                            accesVehicle = false
                        end,
                        onSelected = function(i)
                            Checked3 = i;
                        end
                    })
                    RageUI.Button("Modifier les permissions", nil, {RightLabel= '→→'}, true, {},ModifGestionRankCrew)
                    RageUI.Button('Supprimer le grade '..gradeSelect, nil, {RightLabel= '→→', Color = {BackgroundColor={236,74,74,200}}}, true, {
                        onSelected = function()
                            local validSuppr = KeyboardInput("SUPP_RANK", "Voulez vous vraiment supprimé le grade (oui/non)", "", 10)
                                if validSuppr == 'oui' then
                                    TriggerServerEvent('crew:DeleteRank', crew[1].crew_name, gradeSelect)
                                    RageUI.CloseAll()
                                    menuOpenCrew = false
                                    ESX.ShowNotification("~r~Crew gestion\n~s~Vous venez de supprimer le grade ~b~  "..gradeSelect, true, true)
                                end
                        end
                    })
                end)
                RageUI.IsVisible(ModifGestionRankCrew, function()
                    while gradeSelect == nil do Wait(5) end
                    RageUI.Separator('↓ Modification de ~b~'..gradeSelect..' ~s~↓')
                    RageUI.Checkbox("Accès Compte partager", nil, Checked, {Style = RageUI.CheckboxStyle.Tick}, {
                        onChecked = function()
                            accesCompte = true
                        end,
                        onUnChecked = function()
                            accesCompte = false
                        end,
                        onSelected = function(i)
                            Checked = i;
                        end
                    })
                    RageUI.Checkbox("Accès Gestion du crew", nil, Checked2, {Style = RageUI.CheckboxStyle.Tick}, {
                        onChecked = function()
                            accesGestion = true
                        end,
                        onUnChecked = function()
                            accesGestion = false
                        end,
                        onSelected = function(i)
                            Checked2 = i;
                        end
                    })
                    RageUI.Checkbox("Accès Véhicule partager", nil, Checked3, {Style = RageUI.CheckboxStyle.Tick}, {
                        onChecked = function()
                            accesVehicle = true
                        end,
                        onUnChecked = function()
                            accesVehicle = false
                        end,
                        onSelected = function(i)
                            Checked3 = i;
                        end
                    })
                    RageUI.Button('Modifier les autorisations', nil, {RightLabel= '→→', Color = {BackgroundColor={110,228,137,200}}}, true, {
                        onSelected = function()
                            TriggerServerEvent('crew:UpdateRank', crew[1].crew_name, gradeSelect, accesCompte,accesGestion,accesVehicle)
                            RageUI.CloseAll()
                            menuOpenCrew = false
                        end
                    })
                end)
                ------Création du crew
                RageUI.IsVisible(CreateCrew, function()
                    RageUI.Button('Nom du crew :', nil, {RightLabel = fullname}, true, {
                        onSelected = function()
                            nom = KeyboardInput('CREW_NAME', "Veuillez entrer le nom de votre crew", "", 20)
                            str_name = nom:gsub("%s", "")
                            str_name = string.gsub(str_name, "%s", "")
                            str_name = string.gsub(str_name, "%p", "")
                            fullname = '~b~'..tostring(str_name)
                        end
                    })
                    RageUI.Button('Grade du boss :', nil, {RightLabel = fullgrade}, true, {
                        onSelected = function()
                            grade = KeyboardInput('CREW_GRADE', "Veuillez entrer le grade ", "", 20)  
                            str_grade = grade:gsub("%s", "")
                            str_grade = string.gsub(str_grade, "%s", "")
                            str_grade = string.gsub(str_grade, "%p", "")
                            fullgrade = '~b~'..tostring(str_grade)
                        end
                    })
                    RageUI.Button('Créé le crew', nil, {RightLabel= '→→', Color = {BackgroundColor={110,228,137,200}}}, true, {
                        onSelected = function()
                            if nom ~= nil and grade ~= nil then
                                TriggerServerEvent('crew:CreateCrew', str_name, str_grade, fullname)
                                RageUI.CloseAll()
                                menuOpenCrew = false
                            else
                                ESX.ShowNotification("~r~Crew création\n~s~Veuillez mettre un ~b~nom~s~ et un ~b~grade~s~ pour créé un crew", true, true)
                            end
                        end
                    })
                end)
            end
        end)
    end
end)