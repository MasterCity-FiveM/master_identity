ESX = nil
local loadingScreenFinished = false
local guiEnabled = false
local finished = true
local viewLoaded = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	
	Citizen.Wait(5000)
	
	while not viewLoaded do
		TriggerServerEvent("master_identity:GetData")
		Citizen.Wait(5000)
	end
end)

RegisterNetEvent('esx_identity:alreadyRegistered')
AddEventHandler('esx_identity:alreadyRegistered', function()
	viewLoaded = true
	TriggerEvent('esx_skin:playerRegistered')
end)

RegisterNetEvent('esx_identity:showRegisterIdentity')
AddEventHandler('esx_identity:showRegisterIdentity', function()
	finished = true
	EnableGui(true)
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

RegisterNUICallback('register', function(data, cb)
	ESX.TriggerServerCallback('esx_identity:registerIdentity', function(callback)
		if callback then
			-- ESX.ShowNotification(_U('thank_you_for_registering'))
			exports.pNotify:SendNotification({text = "به سرور مَسترسیتی خوش آمدید.", type = "success", timeout = 30000})
			exports.pNotify:SendNotification({text = "با مراجعه به دیسکورد، از آخرین اخبار و ایونت ها با خبر شوید.", type = "success", timeout = 30000})
			-- bayad pak she badan
			exports.pNotify:SendNotification({text = "ایونت فعال: پول اوسی با مبالغ 500 تومان، 400 تومان، 300 تومان.", type = "success", timeout = 30000})
			finished = false
			EnableGui(false)
			
			TriggerEvent('esx_skin:playerRegistered')
			Wait(100)
			Location = math.random(1,7)
			ESX.Game.Teleport(PlayerPedId(), Config.SpawnPoint[Location].postion, function()
				SetEntityHeading(PlayerPedId(), Config.SpawnPoint[Location].heading)
			end)
			TriggerEvent('mskincreator:loadMenu')
			Wait(1000)
		else
			ESX.ShowNotification(_U('registration_error'))
			Wait(1000)
		end
	end, data)
end)

RegisterNUICallback("UILoaded", function(data)
	viewLoaded = true
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