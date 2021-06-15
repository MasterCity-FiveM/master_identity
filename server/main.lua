ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	local _source = source
	Citizen.Wait(1000)
	checkIdentity(xPlayer, _source)
end)

RegisterNetEvent('master_identity:GetData')
AddEventHandler('master_identity:GetData', function()
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	checkIdentity(xPlayer, _source)
end)

function checkIdentity(xPlayer, src)
	if xPlayer == nil then
		if src ~= nil then
			DropPlayer(src, 'Please reconnect!!!')
		end
		
		return
	end
	MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height, phone, verified FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		if result[1] then
			if result[1].firstname ~= nil and result[1].lastname ~= nil and result[1].firstName ~= '' and result[1].lastName ~= '' then
				xPlayer.setName(('%s %s'):format(result[1].firstName, result[1].lastName))
				xPlayer.set('firstName', result[1].firstName)
				xPlayer.set('lastName', result[1].lastName)
				xPlayer.set('dateofbirth', '2020-10-10')
				xPlayer.set('sex', result[1].sex)
				xPlayer.set('height', '70')
				xPlayer.set('verified', tostring('1'))
				xPlayer.set('phone', tostring('0915'))
				Citizen.Wait(1000)
				TriggerClientEvent('esx_identity:alreadyRegistered', xPlayer.source)
				TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = "از ورود مجدد شما خرسندیم، امیدواریم لحظات خوبی داشته باشید.", type = "info", timeout = 15000, layout = "bottomCenter"})
			else
				xPlayer.set('verified', tostring('0'))
				TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
			end
			
			if GetPlayerName(xPlayer.source) ~= nil then
				MySQL.Async.execute('UPDATE users SET steamname = @steamname WHERE identifier = @identifier', {
					['@identifier']  = xPlayer.identifier,
					['@steamname'] = GetPlayerName(xPlayer.source)
				})
			end
		else
			DropPlayer(xPlayer.source, 'Please reconnect!!!')
		end
	end)
end

ESX.RegisterServerCallback('esx_identity:registerIdentity', function(source, cb, data)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		--ESX.RunCustomFunction("anti_ddos", xPlayer.source, 'esx_identity:registerIdentity', {})
		if xPlayer.verified == '0' and data ~= nil and data.firstname ~= nil and data.lastname ~= nil and data.sex ~= nil and checkNameFormat(data.firstname) and checkNameFormat(data.lastname) and checkSexFormat(data.sex) then
			currentIdentity = {
				firstName = formatName(data.firstname),
				lastName = formatName(data.lastname),
				dateOfBirth = '2020-10-10',
				sex = data.sex,
				height = '70',
				verified = '1',
				phone = '0915'
			}

			xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
			xPlayer.set('firstName', currentIdentity.firstName)
			xPlayer.set('lastName', currentIdentity.lastName)
			xPlayer.set('dateofbirth', '2020-10-10')
			xPlayer.set('sex', currentIdentity.sex)
			xPlayer.set('height', '70')
			xPlayer.set('verified', '1')
			xPlayer.set('phone', currentIdentity.phone)

			xPlayer.setfirstname(currentIdentity.firstName)
			xPlayer.setlastname(currentIdentity.lastName)
			
			saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
			cb(true)
		else
			cb(false)
		end
	end
end)

function saveIdentityToDatabase(identifier, identity)
	MySQL.Sync.execute('UPDATE users SET firstname = @firstname, lastname = @lastname, dateofbirth = @dateofbirth, sex = @sex, height = @height, verified = @verified, phone = @phone WHERE identifier = @identifier', {
		['@identifier']  = identifier,
		['@firstname'] = identity.firstName,
		['@lastname'] = identity.lastName,
		['@dateofbirth'] = identity.dateOfBirth,
		['@sex'] = identity.sex,
		['@height'] = identity.height,
		['@verified'] = identity.verified,
		['@phone'] = identity.phone
	})
end

function checkNameFormat(name)
	if name == nil or name == '' then
		return false
	end

	if not checkAlphanumeric(name) then
		if not checkForNumbers(name) then
			local stringLength = string.len(name)
			if stringLength > 0 and stringLength < Config.MaxNameLength then
				return true
			else
				return false
			end
		else
			return false
		end
	else
		return false
	end
end

function checkSexFormat(sex)
	if sex == nil or sex == '' then
		return false
	end

	if sex == "m" or sex == "M" or sex == "f" or sex == "F" then
		return true
	else
		return false
	end
end

function formatName(name)
	local loweredName = convertToLowerCase(name)
	local formattedName = convertFirstLetterToUpper(loweredName)
	return formattedName
end

function convertToLowerCase(str)
	return string.lower(str)
end

function convertFirstLetterToUpper(str)
	return str:gsub("^%l", string.upper)
end

function checkAlphanumeric(str)
	return (string.match(str, "%W"))
end

function checkForNumbers(str)
	return (string.match(str,"%d"))
end
