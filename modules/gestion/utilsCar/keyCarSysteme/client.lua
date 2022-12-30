local AntiSpam = false

Keys.Register("U", "CleCar", "Dévérouiller le véhicule", function()
    local closetCar = GetClosestVehicle(GetEntityCoords(PlayerPedId()), 5.0, 0, 127)
    local plate = GetVehicleNumberPlateText(closetCar)
    local Autorisation = nil
    
    if AntiSpam == false then
        if plate ~= nil then
            ESX.TriggerServerCallback("keyCarSysteme:ChekAutorisation", function(result)
                Autorisation = result
            end, plate)
            while Autorisation == nil do Wait(5) end
            if Autorisation == true then
               local LockStatu = GetVehicleDoorLockStatus(closetCar)
               RequestAnimDict("anim@mp_player_intmenu@key_fob@")
               while not HasAnimDictLoaded("anim@mp_player_intmenu@key_fob@") do
                   Wait(0)
               end
               if LockStatu == 1 then
                SetVehicleDoorShut(closetCar, 0, false)
                SetVehicleDoorShut(closetCar, 1, false)
                SetVehicleDoorShut(closetCar, 2, false)
                SetVehicleDoorShut(closetCar, 3, false)
                PlayVehicleDoorCloseSound(closetCar, 1)
                if not IsPedInAnyVehicle(PlayerPedId(), true) then
                    TaskPlayAnim(PlayerPedId(), "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                end
                ESX.ShowNotification("~r~Voiture ~s~\nVous avez fermer le véhicule ~b~"..plate, true, true, nil)
                SetVehicleDoorsLocked(closetCar, 2)
               else
                if not IsPedInAnyVehicle(PlayerPedId(), true) then
                    TaskPlayAnim(PlayerPedId(), "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
                end
                ESX.ShowNotification("~r~Voiture ~s~\nVous avez ouvert le véhicule ~b~"..plate, true, true, nil)
                SetVehicleDoorsLocked(closetCar, 1)
               end
            else
                ESX.ShowNotification("~r~Voiture ~s~\nVous n'avez pas les clés de ce véhicule", true, true, nil)
            end
            AntiSpam = true
            SetTimeout(2000, function()
                AntiSpam = false
            end)
        else
            ESX.ShowNotification("~r~Voiture ~s~\nAucune voiture autour de vous", true, true, nil)
        end

    end   
end)

