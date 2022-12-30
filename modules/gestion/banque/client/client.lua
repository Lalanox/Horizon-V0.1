local menuOpen = false
local CompteSelect = {}
local CompteSharedSelect = {}
local moneySociety = {}
local _Tgs = TriggerServerEvent

local BanqueMenu = RageUI.CreateMenu("Banque", "Vos comptes")
BanqueMenu.Closed = function()
    menuOpen = false
end

local subMenuPersonnel = RageUI.CreateSubMenu(BanqueMenu, "BANQUE", "Compte Personnel")
local subMenuCreeCompte = RageUI.CreateSubMenu(BanqueMenu, "BANQUE", "Compte Personnel")
local subMenuModifCompte = RageUI.CreateSubMenu(subMenuPersonnel, "BANQUE", "Compte Personnel")
local subMenuCreeCompteNotNew = RageUI.CreateSubMenu(subMenuPersonnel, "BANQUE", "Compte Personnel")
local subMenuLogsCompte = RageUI.CreateSubMenu(subMenuModifCompte, "BANQUE", "Compte Personnel")
local subMenuLogsCompteDepot = RageUI.CreateSubMenu(subMenuLogsCompte, "BANQUE", "Compte Personnel")
local subMenuLogsCompteRetrait = RageUI.CreateSubMenu(subMenuLogsCompte, "BANQUE", "Compte Personnel")
local subMenuLogsCompteVirementEnvoye = RageUI.CreateSubMenu(subMenuLogsCompte, "BANQUE", "Compte Personnel")
local subMenuLogsCompteVirementRecu = RageUI.CreateSubMenu(subMenuLogsCompte, "BANQUE", "Compte Personnel")

----------------

local subMenuPartager = RageUI.CreateSubMenu(BanqueMenu, "BANQUE", "Compte Partager")
local subMenuPartagerNewAccount = RageUI.CreateSubMenu(subMenuPartager, "BANQUE", "Compte Partager")
local subMenuPartagerHistorique = RageUI.CreateSubMenu(subMenuPartager, "BANQUE", "Compte Partager")
local subMenuLogsComptePartagerDepot = RageUI.CreateSubMenu(subMenuPartagerHistorique, "BANQUE", "Compte Partager")
local subMenuLogsComptePartagerRetrait = RageUI.CreateSubMenu(subMenuPartagerHistorique, "BANQUE", "Compte Partager")
local subMenuLogsComptePartagerVirementEnvoye = RageUI.CreateSubMenu(subMenuPartagerHistorique, "BANQUE", "Compte Partager")
local subMenuLogsComptePartagerVirementRecu = RageUI.CreateSubMenu(subMenuPartagerHistorique, "BANQUE", "Compte Partager")

----------------

local subMenuSociety = RageUI.CreateSubMenu(BanqueMenu, "BANQUE", "Compte Entreprise")



ChekPlayerCompte = function()
    ESX.TriggerServerCallback('banque:ChekCompte', function(result)
        BanqueCompte = result
    end)     
end

GetCrew = function()
    ESX.TriggerServerCallback('crew:GetRankCrew',function(resultat)
        crew = resultat
    end)
end

GetAccountOfCrew = function(crew, rank)
    ESX.TriggerServerCallback('banque:chekAccountCrew',function(resultat)
        accountCrew = resultat
    end, crew, rank)
end

InfoPlayer = function()
    ESX.TriggerServerCallback('banque:InfoPlayer', function(otherResult)
        PlayerInf = otherResult
    end)      
end

allAccountPlayer = function()
    ESX.TriggerServerCallback('banque:accountPlayer', function(result)
        accounts = result
    end)
end

LogsAccounts = function(compte)
    ESX.TriggerServerCallback('banque:LogsAccountsRet', function(result)
        recu = result
    end, compte)

    ESX.TriggerServerCallback('banque:LogsAccountsDep', function(resultat2)
        dep = resultat2
    end, compte)

    ESX.TriggerServerCallback('banque:LogsAccountsVirRecu', function(resultat3)
        virRecu = resultat3
    end, compte)

    ESX.TriggerServerCallback('banque:LogsAccountsVirEnv', function(resultat4)
        virEnv = resultat4
    end, compte)
end


GetSocietyPlayer = function(playerSociety)
    ESX.TriggerServerCallback('banque:societyPlayer', function(resultat)
        moneySociety = resultat
    end, playerSociety)
end



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

local isInteger = function(str)
    return not (str == "" or str:find("%D"))  
end

len = function (table)
    local index = 0
    for k,v in pairs(table) do
        index = index +1
    end
    return index
end

BanqueRui = function (where, type)
    if type == 'Banque' then
        if menuOpen == false then
            menuOpen = true
            RageUI.Visible(BanqueMenu, true)
            ChekPlayerCompte()
            InfoPlayer()
            allAccountPlayer()
            GetCrew()
            while crew == nil do Wait(5) end
            for k,v in pairs(Banque.accountName) do
                if k == ESX.GetPlayerData().job.name then
                    playerJob = k 
                    playerSociety = v
                end
            end
            if playerSociety ~= nil then
                GetSocietyPlayer(playerSociety)
            end
            Wait(100)
            while InfoPlayer == nil do Wait(5) end
            Citizen.CreateThread(function()
                while menuOpen == true do 
                    RageUI.IsVisible(BanqueMenu, function()
                        RageUI.Button("Compte Pesonnel", nil, {RightLabel= '→→'}, true, {},subMenuPersonnel)
                        RageUI.Button("Compte Partager", nil, {RightLabel= '→→'}, json.encode(crew) ~= '[[]]', {
                            onSelected = function()
                                GetAccountOfCrew(crew[1].crew_name, crew[1].crew_grade)
                                while accountCrew == nil do Wait(5) end
                            end
                        }, subMenuPartager)
                        RageUI.Button("Compte Entreprise", nil, {RightLabel= '→→'}, ESX.GetPlayerData().job['grade_name'] == 'patron', {}, subMenuSociety)
                    end)
                    RageUI.IsVisible(subMenuPersonnel, function()
                        if json.encode(BanqueCompte) == '[]' then 
                            RageUI.Separator('')
                            RageUI.Separator('Vous n\'avez pas de ~g~compte')
                            RageUI.Separator('')
                            RageUI.Button("Créé un compte", nil, {RightLabel= '→→'}, true, {}, subMenuCreeCompte)
                        else
                            RageUI.Separator('↓ Vos ~g~comptes ~s~'..len(accounts)..'/'..Banque.MaxAccount..' ↓')
                            for k,v in pairs(accounts) do
                                RageUI.Button("Compte N° "..v.compte, nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        CompteSelect = v
                                    end
                                },subMenuModifCompte)
                            end
                            if len(accounts) < Banque.MaxAccount then
                                RageUI.Button("Créé un compte", nil, {RightLabel= '→→', Color = {BackgroundColor={110,228,137,200}}}, true, {}, subMenuCreeCompteNotNew)
                            end
                        end
                    end)
                    RageUI.IsVisible(subMenuCreeCompte, function()
                        RageUI.Button("Nom : ~b~"..PlayerInf[1]['lastname'], nil, {}, false, {})
                        RageUI.Button("Prénom : ~b~"..PlayerInf[1]['firstname'], nil, {}, false, {})
                        RageUI.Button("Date : ~b~"..PlayerInf[1]['dateofbirth'], nil, {}, false, {})
                        RageUI.Button("Confirmé les ~g~informations", nil, {}, true, {
                            onSelected = function()
                                _Tgs('banque:createAccount', 'new')
                                RageUI.CloseAll()
                                menuOpen = false
                                ESX.ShowNotification("~r~Banque\n~s~Vous avez bien créé un compte", true, true)
                            end
                        })
                    end)
                    RageUI.IsVisible(subMenuCreeCompteNotNew, function()
                        RageUI.Button("Nom : ~b~"..PlayerInf[1]['lastname'], nil, {}, false, {})
                        RageUI.Button("Prénom : ~b~"..PlayerInf[1]['firstname'], nil, {}, false, {})
                        RageUI.Button("Date : ~b~"..PlayerInf[1]['dateofbirth'], nil, {}, false, {})
                        RageUI.Button("Confirmé les ~g~informations", nil, {}, true, {
                            onSelected = function()
                                _Tgs('banque:createAccount', 'notNew')
                                RageUI.CloseAll()
                                menuOpen = false
                                ESX.ShowNotification("~r~Banque\n~s~Vous avez bien créé un compte", true, true)
                            end
                        })
                    end)
                    RageUI.IsVisible(subMenuModifCompte, function()
                        RageUI.Separator('Numéro du compte : ~b~'..tostring(CompteSelect.compte))
                        RageUI.Separator('Solde du compte : ~g~'..tostring(CompteSelect.solde)..' $')
                        if CompteSelect.actuel == true then 
                            RageUI.Separator('Statu du compte :~o~ Courant')
                        end
                        RageUI.Button('Effectuer un virement', nil, {RightLabel= '→→'}, true, {
                            onSelected = function()
                                toAccountVirement = KeyboardInput("ACCOUNT_BANQUE", "Numéro de compte", "", 10)
                                amountToVirement = KeyboardInput("AMOUNT_BANQUE" , "Combien voulez vous envoyez", "", 10)
                                if toAccountVirement or amountToVirement ~= nil then 
                                    if isInteger(amountToVirement) and isInteger(amountToVirement) then
                                        if tonumber(amountToVirement) > tonumber(CompteSelect.solde) then
                                            ESX.ShowNotification("~r~Banque\n~s~Vous n'avez pas assez d'argent sur ce compte", true, true)
                                        else
                                            _Tgs('banque:doVirement', CompteSelect.compte, CompteSelect.solde, toAccountVirement, amountToVirement, where)
                                            RageUI.CloseAll()
                                            menuOpen = false
                                        end
                                    else
                                        ESX.ShowNotification("~r~Banque\n~s~Veuillez saisir un suelement des ~b~nombres", true, true)
                                    end
                                end
                            end
                        })
                        RageUI.Button('Retirer de l\'argent', nil, {RightLabel= '→→'}, true, {
                            onSelected = function()
                                local priceRemove = KeyboardInput("REMOVE_BANQUE", "Montant a retirer", "", 20)
                                if tonumber(priceRemove) then
                                    _Tgs('banque:money', 'rmv', CompteSelect.compte, priceRemove, where)
                                    RageUI.CloseAll()
                                    menuOpen = false
                                else
                                    ESX.ShowNotification("~r~Banque\n~s~Veuillez rentrez un montant valide", true, true)
                                end
                            end
                        })
                        RageUI.Button('Déposer de l\'argent', nil, {RightLabel= '→→'}, true, {
                            onSelected = function()
                                local priceAdd = KeyboardInput("ADD_BANQUE", "Montant a deposer", "", 20)
                                if tonumber(priceAdd) then
                                    _Tgs('banque:money', 'add', CompteSelect.compte, priceAdd, where)
                                    RageUI.CloseAll()
                                    menuOpen = false
                                else
                                    ESX.ShowNotification("~r~Banque\n~s~Veuillez rentrez un montant valide", true, true)
                                end
                            end
                        })
                        RageUI.Button('Historique des transactions', nil, {RightLabel= '→→'}, true, {
                            onSelected = function()
                                LogsAccounts(CompteSelect.compte)
                            end
                        },subMenuLogsCompte)
                        if CompteSelect.actuel == false then
                            RageUI.Button('Passer le compte en tant que courant', nil, {RightLabel= '→→'}, true, {
                                onSelected = function()
                                    local validCourant = KeyboardInput("SUPP_BANQUE", "Voulez vous vraiment changer le statu du compte (oui/non)", "", 10)
                                    if validCourant == 'oui' then
                                        _Tgs('banque:changeStatu', CompteSelect.compte)
                                        RageUI.CloseAll()
                                        menuOpen = false
                                        ESX.ShowNotification("~r~Banque\n~s~Vous venez de passer votre compte~b~ N°"..CompteSelect.compte..'~s~ en ~g~courant', true, true)
                                    end
                                end 
                            })
                        end
                        RageUI.Button('Supprimer le compte', nil, {RightLabel= '→→', Color = {BackgroundColor={236,74,74,200}}}, true, {
                            onSelected = function()
                                local validSuppr = KeyboardInput("SUPP_BANQUE", "Voulez vous vraiment supprimé le compte (oui/non)", "", 10)
                                if validSuppr == 'oui' then
                                    _Tgs('banque:deleteAccount', CompteSelect.compte)
                                    RageUI.CloseAll()
                                    menuOpen = false
                                    ESX.ShowNotification("~r~Banque\n~s~Vous venez de supprimer votre compte~b~ N°"..CompteSelect.compte, true, true)
                                end
                            end
                        })
                    end)
                        RageUI.IsVisible(subMenuLogsCompte, function()
                            RageUI.Button('Dépôt', nil, {RightLabel= '→→'}, true, {}, subMenuLogsCompteDepot)
                            RageUI.Button('Retrait', nil, {RightLabel= '→→'}, true, {}, subMenuLogsCompteRetrait)
                            RageUI.Button('Virement envoyé', nil, {RightLabel= '→→'}, true, {}, subMenuLogsCompteVirementEnvoye)
                            RageUI.Button('Virement reçu', nil, {RightLabel= '→→'}, true, {}, subMenuLogsCompteVirementRecu)
                        end)
                        RageUI.IsVisible(subMenuLogsCompteDepot, function()
                            if len(dep) > 0 then
                                for k,v in pairs(dep) do
                                    RageUI.Button('Transaction N°~b~'..v.id, 'ID N°~b~'..v.id ..'\n~s~Type : ~b~'..v.type..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsCompteRetrait, function()
                            if len(recu) > 0 then
                                for k,v in pairs(recu) do
                                    RageUI.Button('Transaction N°~b~'..v.id, 'ID N°~b~'..v.id ..'\n~s~Type : ~b~'..v.type..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsCompteVirementEnvoye, function()
                            if len(virEnv) > 0 then
                                for k,v in pairs(virEnv) do
                                    RageUI.Button('Transaction N°~b~'..v.id,'ID N°~b~'..v.id ..'\n~s~Destinataire : ~b~ Compte N°'..v.recepteur..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsCompteVirementRecu, function()
                            if len(virRecu) > 0 then
                                for k,v in pairs(virRecu) do
                                    RageUI.Button('Transaction N°~b~'..v.id,'ID N°~b~'..v.id ..'\n~s~Auteur : ~b~ Compte N°'..v.emetteur..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuPartager, function()
                            RageUI.Separator('↓ Votre crew : ~b~'..crew[1].crew_name..'~s~ ↓')
                            while accountCrew == nil do Wait(5) end
                        
                            if accountCrew == 'NotallowCreation' or accountCrew == 'NotAllow' then 
                                RageUI.Separator()
                                RageUI.Separator("Vous n'aves pas ~r~la permission~s~ de ")
                                RageUI.Separator(" consulter ce compte")
                                RageUI.Separator()
                                RageUI.Button('Revenir au menu principale', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        RageUI.GoBack()
                                    end
                                })
                            elseif accountCrew == 'allowCreation' then
                                RageUI.Separator()
                                RageUI.Separator("Vous n'aves pas encore de ~g~compte partager")
                                RageUI.Separator()
                                RageUI.Button('Créé un compte partager', nil, {RightLabel= '→→'}, true, {}, subMenuPartagerNewAccount)
                            else    
                                RageUI.Separator('Numéro du compte : ~b~'..accountCrew[1].compte)
                                RageUI.Separator('Solde du compte : ~g~'..accountCrew[1].solde..' $')
                                RageUI.Button('Effectuer un virement', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        toAccountVirement = KeyboardInput("ACCOUNT_BANQUE", "Numéro de compte", "", 10)
                                        amountToVirement = KeyboardInput("AMOUNT_BANQUE" , "Combien voulez vous envoyez", "", 10)
                                        if toAccountVirement or amountToVirement ~= nil then 
                                            if isInteger(toAccountVirement) and isInteger(amountToVirement) then
                                                if tonumber(amountToVirement) > tonumber(accountCrew[1].solde) then
                                                    ESX.ShowNotification("~r~Banque\n~s~Vous n'avez pas assez d'argent sur ce compte", true, true)
                                                else
                                                    _Tgs('banque:doVirement', accountCrew[1].compte, accountCrew[1].solde, toAccountVirement, amountToVirement, where)
                                                    RageUI.CloseAll()
                                                    menuOpen = false
                                                end
                                            else
                                                ESX.ShowNotification("~r~Banque\n~s~Veuillez saisir un suelement des ~b~nombres", true, true)
                                            end
                                        end
                                    end
                                })
                                RageUI.Button('Retirer de l\'argent', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        local priceRemove = KeyboardInput("REMOVE_BANQUE", "Montant a retirer", "", 20)
                                        if tonumber(priceRemove) then
                                            _Tgs('banque:money', 'rmv', accountCrew[1].compte, priceRemove, where)
                                            RageUI.CloseAll()
                                            menuOpen = false
                                        else
                                            ESX.ShowNotification("~r~Banque\n~s~Veuillez rentrez un montant valide", true, true)
                                        end
                                    end
                                })
                                RageUI.Button('Déposer de l\'argent', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        local priceAdd = KeyboardInput("ADD_BANQUE", "Montant a deposer", "", 20)
                                        if tonumber(priceAdd) then
                                            _Tgs('banque:money', 'add', accountCrew[1].compte, priceAdd, where)
                                            RageUI.CloseAll()
                                            menuOpen = false
                                        else
                                            ESX.ShowNotification("~r~Banque\n~s~Veuillez rentrez un montant valide", true, true)
                                        end
                                    end
                                })
                                RageUI.Button('Historique des transactions', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        LogsAccounts(accountCrew[1].compte)
                                    end
                                },subMenuPartagerHistorique)
                            end
                        end)
                        RageUI.IsVisible(subMenuPartagerHistorique, function()
                            RageUI.Button('Dépôt', nil, {RightLabel= '→→'}, true, {}, subMenuLogsComptePartagerDepot)
                            RageUI.Button('Retrait', nil, {RightLabel= '→→'}, true, {}, subMenuLogsComptePartagerRetrait)
                            RageUI.Button('Virement envoyé', nil, {RightLabel= '→→'}, true, {}, subMenuLogsComptePartagerVirementEnvoye)
                            RageUI.Button('Virement reçu', nil, {RightLabel= '→→'}, true, {}, subMenuLogsComptePartagerVirementRecu)
                        end)
                        RageUI.IsVisible(subMenuLogsComptePartagerDepot, function()
                            if len(dep) > 0 then
                                for k,v in pairs(dep) do
                                    RageUI.Button('Transaction N°~b~'..v.id, 'ID N°~b~'..v.id ..'\n~s~Type : ~b~'..v.type..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu..'\n~s~Auteur : ~b~'..v.auteur,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsComptePartagerRetrait, function()
                            if len(recu) > 0 then
                                for k,v in pairs(recu) do
                                    RageUI.Button('Transaction N°~b~'..v.id, 'ID N°~b~'..v.id ..'\n~s~Type : ~b~'..v.type..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu..'\n~s~Auteur : ~b~'..v.auteur,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsComptePartagerVirementEnvoye, function()
                            if len(virEnv) > 0 then
                                for k,v in pairs(virEnv) do
                                    RageUI.Button('Transaction N°~b~'..v.id,'ID N°~b~'..v.id ..'\n~s~Destinataire : ~b~ Compte N°'..v.recepteur..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu..'\n~s~Auteur : ~b~'..v.auteur,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsComptePartagerVirementRecu, function()
                            if len(virRecu) > 0 then
                                for k,v in pairs(virRecu) do
                                    RageUI.Button('Transaction N°~b~'..v.id,'ID N°~b~'..v.id ..'\n~s~Auteur : ~b~ Compte N°'..v.emetteur..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu..'\n~s~Auteur : ~b~'..v.auteur,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuPartagerNewAccount, function()
                            RageUI.Button("Nom : ~b~"..PlayerInf[1]['lastname'], nil, {}, false, {})
                            RageUI.Button("Prénom : ~b~"..PlayerInf[1]['firstname'], nil, {}, false, {})
                            RageUI.Button("Date : ~b~"..PlayerInf[1]['dateofbirth'], nil, {}, false, {})
                            RageUI.Button("Nom du crew :  ~b~"..crew[1].crew_name, nil, {}, false, {})
                            RageUI.Button("Statu dans le crew :  ~b~"..crew[1].crew_grade, nil, {}, false, {})
                            RageUI.Button("Confirmé les ~g~informations", nil, {}, true, {
                                onSelected = function()
                                    _Tgs('banque:createAccount', 'newShared', crew[1].crew_name)
                                    RageUI.CloseAll()
                                    menuOpen = false
                                    ESX.ShowNotification("~r~Banque\n~s~Vous avez bien créé un compte avec le crew : ~b~"..crew[1].crew_name, true, true)
                                end
                            })
                        end)
                        RageUI.IsVisible(subMenuSociety, function()
                            RageUI.Separator('Votre société ~b~'..tostring(ESX.GetPlayerData().job.label))
                            RageUI.Separator('Solde de l\'entreprise ~g~'..ESX.Math.GroupDigits(moneySociety)..' $')
                            RageUI.Button('Retirer de l\'argent', nil, {RightLabel= '→→'}, true, {
                                onSelected = function()
                                    local moneyRmv = KeyboardInput("MSOC_BANQUE", "Montant à retirer", "", 10)
                                    if tonumber(moneyRmv) then
                                        _Tgs('banque:updateMoneySociety','sup' ,playerSociety ,moneyRmv)
                                        RageUI.CloseAll()
                                        menuOpen = false
                                    end
                                end
                            })
                            RageUI.Button('Déposer de l\'argent', nil, {RightLabel= '→→'}, true, {
                                onSelected = function()
                                    local moneyAd = KeyboardInput("MSO_BANQUE", "Montant à retirer", "", 10)
                                    if tonumber(moneyAd) then
                                        _Tgs('banque:updateMoneySociety','ad' ,playerSociety ,moneyAd)
                                        RageUI.CloseAll()
                                        menuOpen = false
                                    end
                                end
                            })
                        end)
                    Wait(0)
                end
            end)
        end
    elseif type == 'ATM' then
        if menuOpen == false then
            menuOpen = true
            RageUI.Visible(BanqueMenu, true)
            ChekPlayerCompte()
            InfoPlayer()
            allAccountPlayer()
            GetCrew()
            while crew == nil do Wait(5) end
            for k,v in pairs(Banque.accountName) do
                if k == ESX.GetPlayerData().job.name then
                    playerJob = k 
                    playerSociety = v
                end
            end
            GetSocietyPlayer(playerSociety)
            Wait(100)
            while InfoPlayer == nil do Wait(5) end
            Citizen.CreateThread(function()
                while menuOpen == true do 
                    RageUI.IsVisible(BanqueMenu, function()
                        RageUI.Button("Compte Pesonnel", nil, {RightLabel= '→→'}, true, {},subMenuPersonnel)
                        RageUI.Button("Compte Partager", nil, {RightLabel= '→→'}, json.encode(crew) ~= '[[]]', {
                            onSelected = function()
                                GetAccountOfCrew(crew[1].crew_name, crew[1].crew_grade)
                                while accountCrew == nil do Wait(5) end
                            end
                        }, subMenuPartager)
                        RageUI.Button("Compte Entreprise", nil, {RightLabel= '→→'}, ESX.GetPlayerData().job['grade_name'] == 'patron', {}, subMenuSociety)
                    end)
                    RageUI.IsVisible(subMenuPersonnel, function()
                        if json.encode(BanqueCompte) == '[]' then 
                            RageUI.Separator('')
                            RageUI.Separator('Allez a la ~b~Pacifique Banque~s pour')
                            RageUI.Separator('ouvrir un compte ')
                            RageUI.Separator('')
                        else
                            RageUI.Separator('↓ Vos ~g~comptes ~s~'..len(accounts)..'/'..Banque.MaxAccount..' ↓')
                            for k,v in pairs(accounts) do
                                RageUI.Button("Compte N° "..v.compte, nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        CompteSelect = v
                                    end
                                },subMenuModifCompte)
                            end
                        end
                    end)
                    RageUI.IsVisible(subMenuModifCompte, function()
                        RageUI.Separator('Numéro du compte : ~b~'..tostring(CompteSelect.compte))
                        RageUI.Separator('Solde du compte : ~g~'..tostring(CompteSelect.solde)..' $')
                        if CompteSelect.actuel == true then 
                            RageUI.Separator('Statu du compte :~o~ Courant')
                        end
                        RageUI.Button('Effectuer un virement', nil, {RightLabel= '→→'}, true, {
                            onSelected = function()
                                toAccountVirement = KeyboardInput("ACCOUNT_BANQUE", "Numéro de compte", "", 10)
                                amountToVirement = KeyboardInput("AMOUNT_BANQUE" , "Combien voulez vous envoyez", "", 10)
                                if toAccountVirement or amountToVirement ~= nil then 
                                    if isInteger(amountToVirement) and isInteger(amountToVirement) then
                                        if tonumber(amountToVirement) > tonumber(CompteSelect.solde) then
                                            ESX.ShowNotification("~r~Banque\n~s~Vous n'avez pas assez d'argent sur ce compte", true, true)
                                        else
                                            _Tgs('banque:doVirement', CompteSelect.compte, CompteSelect.solde, toAccountVirement, amountToVirement, where)
                                            RageUI.CloseAll()
                                            menuOpen = false
                                        end
                                    else
                                        ESX.ShowNotification("~r~Banque\n~s~Veuillez saisir un suelement des ~b~nombres", true, true)
                                    end
                                end
                            end
                        })
                        RageUI.Button('Retirer de l\'argent', nil, {RightLabel= '→→'}, true, {
                            onSelected = function()
                                local priceRemove = KeyboardInput("REMOVE_BANQUE", "Montant a retirer", "", 20)
                                if tonumber(priceRemove) then
                                    _Tgs('banque:money', 'rmv', CompteSelect.compte, priceRemove, where)
                                    RageUI.CloseAll()
                                    menuOpen = false
                                else
                                    ESX.ShowNotification("~r~Banque\n~s~Veuillez rentrez un montant valide", true, true)
                                end
                            end
                        })
                        RageUI.Button('Déposer de l\'argent', nil, {RightLabel= '→→'}, true, {
                            onSelected = function()
                                local priceAdd = KeyboardInput("ADD_BANQUE", "Montant a deposer", "", 20)
                                if tonumber(priceAdd) then
                                    _Tgs('banque:money', 'add', CompteSelect.compte, priceAdd, where)
                                    RageUI.CloseAll()
                                    menuOpen = false
                                else
                                    ESX.ShowNotification("~r~Banque\n~s~Veuillez rentrez un montant valide", true, true)
                                end
                            end
                        })
                        RageUI.Button('Historique des transactions', nil, {RightLabel= '→→'}, true, {
                            onSelected = function()
                                LogsAccounts(CompteSelect.compte)
                            end
                        },subMenuLogsCompte)
                    end)
                        RageUI.IsVisible(subMenuLogsCompte, function()
                            RageUI.Button('Dépôt', nil, {RightLabel= '→→'}, true, {}, subMenuLogsCompteDepot)
                            RageUI.Button('Retrait', nil, {RightLabel= '→→'}, true, {}, subMenuLogsCompteRetrait)
                            RageUI.Button('Virement envoyé', nil, {RightLabel= '→→'}, true, {}, subMenuLogsCompteVirementEnvoye)
                            RageUI.Button('Virement reçu', nil, {RightLabel= '→→'}, true, {}, subMenuLogsCompteVirementRecu)
                        end)
                        RageUI.IsVisible(subMenuLogsCompteDepot, function()
                            if len(dep) > 0 then
                                for k,v in pairs(dep) do
                                    RageUI.Button('Transaction N°~b~'..v.id, 'ID N°~b~'..v.id ..'\n~s~Type : ~b~'..v.type..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsCompteRetrait, function()
                            if len(recu) > 0 then
                                for k,v in pairs(recu) do
                                    RageUI.Button('Transaction N°~b~'..v.id, 'ID N°~b~'..v.id ..'\n~s~Type : ~b~'..v.type..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsCompteVirementEnvoye, function()
                            if len(virEnv) > 0 then
                                for k,v in pairs(virEnv) do
                                    RageUI.Button('Transaction N°~b~'..v.id,'ID N°~b~'..v.id ..'\n~s~Destinataire : ~b~ Compte N°'..v.recepteur..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsCompteVirementRecu, function()
                            if len(virRecu) > 0 then
                                for k,v in pairs(virRecu) do
                                    RageUI.Button('Transaction N°~b~'..v.id,'ID N°~b~'..v.id ..'\n~s~Auteur : ~b~ Compte N°'..v.emetteur..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuPartager, function()
                            RageUI.Separator('↓ Votre crew : ~b~'..crew[1].crew_name..'~s~ ↓')
                            while accountCrew == nil do Wait(5) end
                        
                            if accountCrew == 'NotallowCreation' or accountCrew == 'NotAllow' then 
                                RageUI.Separator()
                                RageUI.Separator("Vous n'aves pas ~r~la permission~s~ de ")
                                RageUI.Separator(" consulter ce compte")
                                RageUI.Separator()
                                RageUI.Button('Revenir au menu principale', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        RageUI.GoBack()
                                    end
                                })
                            elseif accountCrew == 'allowCreation' then
                                RageUI.Separator()
                                RageUI.Separator("Vous n'aves pas encore de ~g~compte partager")
                                RageUI.Separator("aller à la ~b~Pacifique Banque")
                                RageUI.Separator()
                            else    
                                RageUI.Separator('Numéro du compte : ~b~'..accountCrew[1].compte)
                                RageUI.Separator('Solde du compte : ~g~'..accountCrew[1].solde..' $')
                                RageUI.Button('Effectuer un virement', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        toAccountVirement = KeyboardInput("ACCOUNT_BANQUE", "Numéro de compte", "", 10)
                                        amountToVirement = KeyboardInput("AMOUNT_BANQUE" , "Combien voulez vous envoyez", "", 10)
                                        if toAccountVirement or amountToVirement ~= nil then 
                                            if isInteger(amountToVirement) and isInteger(amountToVirement) then
                                                if tonumber(amountToVirement) > tonumber(accountCrew[1].solde) then
                                                    ESX.ShowNotification("~r~Banque\n~s~Vous n'avez pas assez d'argent sur ce compte", true, true)
                                                else
                                                    _Tgs('banque:doVirement', accountCrew[1].compte, accountCrew[1].solde, toAccountVirement, amountToVirement, where)
                                                    RageUI.CloseAll()
                                                    menuOpen = false
                                                end
                                            else
                                                ESX.ShowNotification("~r~Banque\n~s~Veuillez saisir un suelement des ~b~nombres", true, true)
                                            end
                                        end
                                    end
                                })
                                RageUI.Button('Retirer de l\'argent', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        local priceRemove = KeyboardInput("REMOVE_BANQUE", "Montant a retirer", "", 20)
                                        if tonumber(priceRemove) then
                                            _Tgs('banque:money', 'rmv', accountCrew[1].compte, priceRemove, where)
                                            RageUI.CloseAll()
                                            menuOpen = false
                                        else
                                            ESX.ShowNotification("~r~Banque\n~s~Veuillez rentrez un montant valide", true, true)
                                        end
                                    end
                                })
                                RageUI.Button('Déposer de l\'argent', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        local priceAdd = KeyboardInput("ADD_BANQUE", "Montant a deposer", "", 20)
                                        if tonumber(priceAdd) then
                                            _Tgs('banque:money', 'add', accountCrew[1].compte, priceAdd, where)
                                            RageUI.CloseAll()
                                            menuOpen = false
                                        else
                                            ESX.ShowNotification("~r~Banque\n~s~Veuillez rentrez un montant valide", true, true)
                                        end
                                    end
                                })
                                RageUI.Button('Historique des transactions', nil, {RightLabel= '→→'}, true, {
                                    onSelected = function()
                                        LogsAccounts(accountCrew[1].compte)
                                    end
                                },subMenuPartagerHistorique)
                            end
                        end)
                        RageUI.IsVisible(subMenuPartagerHistorique, function()
                            RageUI.Button('Dépôt', nil, {RightLabel= '→→'}, true, {}, subMenuLogsComptePartagerDepot)
                            RageUI.Button('Retrait', nil, {RightLabel= '→→'}, true, {}, subMenuLogsComptePartagerRetrait)
                            RageUI.Button('Virement envoyé', nil, {RightLabel= '→→'}, true, {}, subMenuLogsComptePartagerVirementEnvoye)
                            RageUI.Button('Virement reçu', nil, {RightLabel= '→→'}, true, {}, subMenuLogsComptePartagerVirementRecu)
                        end)
                        RageUI.IsVisible(subMenuLogsComptePartagerDepot, function()
                            if len(dep) > 0 then
                                for k,v in pairs(dep) do
                                    RageUI.Button('Transaction N°~b~'..v.id, 'ID N°~b~'..v.id ..'\n~s~Type : ~b~'..v.type..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu..'\n~s~Auteur : ~b~'..v.auteur,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsComptePartagerRetrait, function()
                            if len(recu) > 0 then
                                for k,v in pairs(recu) do
                                    RageUI.Button('Transaction N°~b~'..v.id, 'ID N°~b~'..v.id ..'\n~s~Type : ~b~'..v.type..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu..'\n~s~Auteur : ~b~'..v.auteur,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsComptePartagerVirementEnvoye, function()
                            if len(virEnv) > 0 then
                                for k,v in pairs(virEnv) do
                                    RageUI.Button('Transaction N°~b~'..v.id,'ID N°~b~'..v.id ..'\n~s~Destinataire : ~b~ Compte N°'..v.recepteur..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu..'\n~s~Auteur : ~b~'..v.auteur,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuLogsComptePartagerVirementRecu, function()
                            if len(virRecu) > 0 then
                                for k,v in pairs(virRecu) do
                                    RageUI.Button('Transaction N°~b~'..v.id,'ID N°~b~'..v.id ..'\n~s~Auteur : ~b~ Compte N°'..v.emetteur..'\n~s~Montant :~b~ '..v.montant..' $\n~s~Date : ~b~'..v.date..'\n~s~Lieu : ~b~'..v.lieu..'\n~s~Auteur : ~b~'..v.auteur,{}, true, {})
                                end
                            else
                                RageUI.Separator('')
                                RageUI.Button('                     Aucune Transaction', nil,{}, true, {})
                                RageUI.Separator('')
                             end
                        end)
                        RageUI.IsVisible(subMenuPartagerNewAccount, function()
                            RageUI.Button("Nom : ~b~"..PlayerInf[1]['lastname'], nil, {}, false, {})
                            RageUI.Button("Prénom : ~b~"..PlayerInf[1]['firstname'], nil, {}, false, {})
                            RageUI.Button("Date : ~b~"..PlayerInf[1]['dateofbirth'], nil, {}, false, {})
                            RageUI.Button("Nom du crew :  ~b~"..crew[1].crew_name, nil, {}, false, {})
                            RageUI.Button("Statu dans le crew :  ~b~"..crew[1].crew_grade, nil, {}, false, {})
                            RageUI.Button("Confirmé les ~g~informations", nil, {}, true, {
                                onSelected = function()
                                    _Tgs('banque:createAccount', 'newShared', crew[1].crew_name)
                                    RageUI.CloseAll()
                                    menuOpen = false
                                    ESX.ShowNotification("~r~Banque\n~s~Vous avez bien créé un compte avec le crew : ~b~"..crew[1].crew_name, true, true)
                                end
                            })
                        end)
                        RageUI.IsVisible(subMenuSociety, function()
                            RageUI.Separator('Votre société ~b~'..tostring(ESX.GetPlayerData().job.label))
                            RageUI.Separator('Solde de l\'entreprise ~g~'..ESX.Math.GroupDigits(moneySociety)..' $')
                            RageUI.Button('Retirer de l\'argent', nil, {RightLabel= '→→'}, true, {
                                onSelected = function()
                                    local moneyRmv = KeyboardInput("MSOC_BANQUE", "Montant à retirer", "", 10)
                                    if tonumber(moneyRmv) then
                                        _Tgs('banque:updateMoneySociety','sup' ,playerSociety ,moneyRmv)
                                        RageUI.CloseAll()
                                        menuOpen = false
                                    end
                                end
                            })
                            RageUI.Button('Déposer de l\'argent', nil, {RightLabel= '→→'}, true, {
                                onSelected = function()
                                    local moneyAd = KeyboardInput("MSO_BANQUE", "Montant à retirer", "", 10)
                                    if tonumber(moneyAd) then
                                        _Tgs('banque:updateMoneySociety','ad' ,playerSociety ,moneyAd)
                                        RageUI.CloseAll()
                                        menuOpen = false
                                    end
                                end
                            })
                        end)
                    Wait(0)
                end
            end)
        end
    end
end


RegisterNetEvent('banque:NotifPayement')
AddEventHandler('banque:NotifPayement', function(motif, value)
    ESX.ShowAdvancedNotification("L.A - Banque", "Débit", "Vous venez d'éfectuer un payement sur votre compte ~o~courant~s~ de ~g~"..value.." $~s~ pour le motif de ~b~"..motif, "CHAR_BANK_FLEECA", 9, true, true)
end)



CreateThread(function()
    while true do 
        local interval = 700
        local ped = PlayerPedId()
        local playerPosition = GetEntityCoords(ped)
        local dstPlayerBanque = #(playerPosition - Banque.Pacifique.pos)
        
        for k,v in pairs(Banque.ATM) do
            local dstPlayerATM = #(playerPosition - v)
        
            if dstPlayerATM <= 1.5 then
                interval = 0
                AddTextEntry("atm", "Appuyez sur ~INPUT_PICKUP~ pour accéder à l'~b~ATM")
                DisplayHelpTextThisFrame("atm", false)
                if IsControlJustPressed(0, 38) then
                    BanqueRui(k, 'ATM')
                end
            end
        
        end
    
        if dstPlayerBanque <= 5.0 then
            interval = 0 
            DrawMarker(20, Banque.Pacifique.pos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 35, 202, 251, 255, true, true, false, true)
            if IsControlJustPressed(0, 38) then
                if dstPlayerBanque <= 2.5 then
                    BanqueRui(Banque.Pacifique.where, 'Banque')
                end
            end
        end
        Wait(interval)
    end

end)
