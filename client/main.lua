ESX = nil
local loadingScreenFinished = false
local guiEnabled = false
local finished = true

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_identity:alreadyRegistered')
AddEventHandler('esx_identity:alreadyRegistered', function()
	mk32_debug_clogger("Already registered")
	TriggerEvent('esx_skin:playerRegistered')
end)

AddEventHandler('esx:loadingScreenOff', function()
	loadingScreenFinished = true
end)

function EnableGui(state)
	SetNuiFocus(state, state)
	guiEnabled = state

	SendNUIMessage({
		type = "enableui",
		enable = state
	})
end

RegisterNetEvent('mk_idnt_error')
AddEventHandler('mk_idnt_error', function(action)
	SendNUIMessage({
		type = action
	})
end)

RegisterNetEvent('esx_identity:showRegisterIdentity')
AddEventHandler('esx_identity:showRegisterIdentity', function()
	mk32_debug_clogger("Show GUI")
	finished = true
	EnableGui(true)
end)

RegisterNUICallback('register', function(data, cb)
	mk32_debug_clogger("Start esx_identity:registerIdentity from client")
	ESX.TriggerServerCallback('esx_identity:registerIdentity', function(callback)
		mk32_debug_clogger("Get submit!")
		if callback then
			mk32_debug_clogger("Registered!")
			-- ESX.ShowNotification(_U('thank_you_for_registering'))
			exports.pNotify:SendNotification({text = "به سرور مَسترسیتی خوش آمدید.", type = "success", timeout = 30000})
			finished = false
			EnableGui(false)
			mk32_debug_clogger("Load ESX Skin!")
			TriggerEvent('esx_skin:playerRegistered')
			mk32_debug_clogger("Load MSkinCreator!")
			TriggerEvent('mskincreator:loadMenu')
			Wait(1000)
		else
			mk32_debug_clogger("Register error")
			ESX.ShowNotification(_U('registration_error'))
			Wait(1000)
		end
	end, data)
end)

RegisterNUICallback('register', function(data, cb)
	ESX.TriggerServerCallback('esx_identity:registerIdentity', function(callback)
		if callback then
			-- ESX.ShowNotification(_U('thank_you_for_registering'))
			EnableGui(false)
			TriggerEvent('esx_skin:playerRegistered')
			TriggerEvent('mskincreator:loadMenu')
			Wait(1000)
		else
			ESX.ShowNotification(_U('registration_error'))
		end
	end, data)
end)

Citizen.CreateThread(function()
	while finished do
		Citizen.Wait(0)

		if guiEnabled then
			DisableControlAction(0, 1,   true) -- LookLeftRight
			DisableControlAction(0, 2,   true) -- LookUpDown
			DisableControlAction(0, 106, true) -- VehicleMouseControlOverride
			DisableControlAction(0, 142, true) -- MeleeAttackAlternate
			DisableControlAction(0, 30,  true) -- MoveLeftRight
			DisableControlAction(0, 31,  true) -- MoveUpDown
			DisableControlAction(0, 21,  true) -- disable sprint
			DisableControlAction(0, 24,  true) -- disable attack
			DisableControlAction(0, 25,  true) -- disable aim
			DisableControlAction(0, 47,  true) -- disable weapon
			DisableControlAction(0, 58,  true) -- disable weapon
			DisableControlAction(0, 263, true) -- disable melee
			DisableControlAction(0, 264, true) -- disable melee
			DisableControlAction(0, 257, true) -- disable melee
			DisableControlAction(0, 140, true) -- disable melee
			DisableControlAction(0, 141, true) -- disable melee
			DisableControlAction(0, 143, true) -- disable melee
			DisableControlAction(0, 75,  true) -- disable exit vehicle
			DisableControlAction(27, 75, true) -- disable exit vehicle
		else
			Citizen.Wait(500)
		end
	end
end)

function mk32_debug_clogger(str)
	if Config.EnableDebugging then
		print(str)
	end
end