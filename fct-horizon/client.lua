Horizon.PlayAnimation = function(set)
    ClearPedTasksImmediately(PlayerPedId())
    RequestAnimDict(set.dict)
    while not HasAnimDictLoaded(set.dict) do Wait(10) end
    TaskPlayAnim(PlayerPedId(), set.dict, set.name, 8.0, 1.0, -1, 1)
    RemoveAnimDict(set.dict)
end

-- Horizon.CreateCamera({20.0, 20.0, 110.0, rotY = -40.0, heading = 10.0, fov = 50.0, AnimTime = 4500})
Horizon.CreateCamera = function(var)
    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", false)
    SetCamActive(cam, true)
    SetCamParams(cam, var[1] or 10.0, var[2] or 10.0, var[3] or 10.0, var.rotY or 1.0, 0.0, var.heading or 200.0, 42.24, 0, 1, 1, 2)
    SetCamCoord(cam, var[1], var[2], var[3])
    SetCamFov(cam, var.fov or 40.0)
    RenderScriptCams(true, var.Anim or true, var.AnimTime or 0, true, true)
    return cam
end

-- Horizon.DeleteCam(varcaméra, {Anim = true, AnimTime = 2000})
Horizon.DeleteCam = function(name, var)
    if DoesCamExist(name) then
        SetCamActive(name, false)
        DestroyCam(name, false, false)
        RenderScriptCams(false, var.Anim or true, var.AnimTime or 0, false, false)
    else
        print("ERROR - LA CAM N'EXISTE PAS")
    end
end

Horizon.getStreetName = function(coords)
	local streetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z);
	return GetStreetNameFromHashKey(streetHash);
end

Horizon.KeyboardInput = function(title, TextEntry, ExampleText, MaxStringLenght)
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