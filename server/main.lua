ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
	mk32_debug_logger("Master Identity starting ...")
	Citizen.Wait(1000)
	checkIdentity(xPlayer)
	Citizen.Wait(1000)
end)

function checkIdentity(xPlayer)
	MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height, phone, verified FROM users WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		if result[1] then
			if tostring(result[1].verified) == '1' then
				mk32_debug_logger("Character verified.")
				xPlayer.setName(('%s %s'):format(result[1].firstName, result[1].lastName))
				xPlayer.set('firstName', result[1].firstName)
				xPlayer.set('lastName', result[1].lastName)
				xPlayer.set('dateofbirth', '2020-10-10')
				xPlayer.set('sex', result[1].sex)
				xPlayer.set('height', '70')
				xPlayer.set('verified', tostring('1'))
				xPlayer.set('phone', tostring(result[1].phone))
				
				Citizen.Wait(1000)
				TriggerClientEvent('esx_identity:alreadyRegistered', xPlayer.source)
				TriggerClientEvent("pNotify:SendNotification", xPlayer.source, { text = "از ورود مجدد شما خرسندیم، امیدواریم لحظات خوبی داشته باشید.", type = "info", timeout = 15000, layout = "bottomCenter"})
			else
				xPlayer.set('verified', tostring('0'))
				mk32_debug_logger("Registered but not verified.")
				TriggerClientEvent('esx_identity:showRegisterIdentity', xPlayer.source)
			end
		else
			mk32_debug_logger("Character not exists!")
			xPlayer.kick("Missing data please reconnect!")
			mk32_debug_logger("Player kicked!")
		end
	end)
end

ESX.RegisterServerCallback('esx_identity:registerIdentity', function(source, cb, data)
	ESX.RunCustomFunction("anti_ddos", source, 'esx_identity:registerIdentity', {data = data})
	mk32_debug_logger("esx_identity:registerIdentity starting ...")
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		if xPlayer.verified == '0' then
			mk32_debug_logger("Checking form submit!")
			if data.step and data.step == 'one' and checkPhoneFormat(data.phone) then
				mk32_debug_logger("Step 1, phone is valid.")
				MySQL.Async.fetchAll('SELECT phone FROM users WHERE phone = @phone', {
					['@phone'] = data.phone
				}, function(result)
					if result[1] then
						mk32_debug_logger("Phone number already exists!")
						TriggerClientEvent('mk_idnt_error', source, 'phone_exists')
						cb(false)
					else
						mk32_debug_logger("Sending SMS!")
						-- SEND SMS
						local APIURL = Config.webAPI .. 'sendsms.php?phone=' .. data.phone
						PerformHttpRequest(APIURL, function (errorCode, resultData, resultHeaders)
							-- print("Returned error code:" .. tostring(errorCode))
							-- print("Returned data:" .. tostring(resultData))
							-- print("Returned result Headers:" .. tostring(resultHeaders))
						end)
						TriggerClientEvent('mk_idnt_error', source, 'goto_step2')
						cb(false)
					end
				end)
			elseif data.step and data.step == 'two' and checkPhoneFormat(data.phone) and checkCodeFormat(data.code) and checkNameFormat(data.firstname) and checkNameFormat(data.lastname) and checkSexFormat(data.sex) then
				mk32_debug_logger("Step 2, everything is look fine, check the phone number again!")
				MySQL.Async.fetchAll('SELECT phone FROM users WHERE phone = @phone', {
					['@phone'] = data.phone
				}, function(result)
					if result[1] then
						mk32_debug_logger("Step 2, Phone is exists, I will kick you!")
						xPlayer.kick("What are you doning?")
						mk32_debug_logger("Player kicked!")
						cb(false)
					else
						mk32_debug_logger("Check verify code!")
						MySQL.Async.fetchAll('SELECT phone FROM verify_codes WHERE phone = @phone AND code = @code', {
							['@phone'] = data.phone,
							['@code'] = data.code
						}, function(result)
							if result[1] then
								mk32_debug_logger("Code is valid.")
								
								currentIdentity = {
									firstName = formatName(data.firstname),
									lastName = formatName(data.lastname),
									dateOfBirth = '2020-10-10',
									sex = data.sex,
									height = '70',
									verified = '1',
									phone = data.phone
								}
			
								xPlayer.setName(('%s %s'):format(currentIdentity.firstName, currentIdentity.lastName))
								xPlayer.set('firstName', currentIdentity.firstName)
								xPlayer.set('lastName', currentIdentity.lastName)
								xPlayer.set('dateofbirth', '2020-10-10')
								xPlayer.set('sex', currentIdentity.sex)
								xPlayer.set('height', '70')
								xPlayer.set('verified', '1')
								xPlayer.set('phone', currentIdentity.phone)
			
								saveIdentityToDatabase(xPlayer.identifier, currentIdentity)
								mk32_debug_logger("Register finished!")
								cb(true)
							else
								TriggerClientEvent('mk_idnt_error', source, 'error_verify')
								mk32_debug_logger("Code is not valid!")
								cb(false)
							end
						end)
					end
				end)
			else
				cb(false)
			end
		else
			mk32_debug_logger("Character already verified!")
			cb(false)
		end
	end
end)

function saveIdentityToDatabase(identifier, identity)
	mk32_debug_logger("Save information...")
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
	mk32_debug_logger("Saved!")
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

function checkPhoneFormat(phone)
	if phone == nil or phone == '' then
		return false
	end
	
	local Numphone = tonumber(phone)
	if Numphone < 09000000000 and Numphone > 09999999999 then
		return false
	else
		return true
	end
end

function checkCodeFormat(code)
	if code == nil or code == '' then
		return false
	end

	local NumCode = tonumber(code)
	if NumCode < 100000 and NumCode > 999999 then
		return false
	else
		return true
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

function mk32_debug_logger(str)
	if Config.EnableDebugging then
		print(str)
	end
end