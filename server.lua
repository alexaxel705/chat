﻿local help = {}
local MainChat = {}
local Zones = {
	[1] = createColRectangle(1441, -1721, 77, 117),
	[2] = createColRectangle(-2364, 72, 79, 155),
	[3] = createColRectangle(2298, 2244, 119, 159),
	[4] = createColRectangle(-2594, -60, 42, 89.5),
	[5] = createColRectangle(-2740, 345, 67.5, 61),
}
for _,el in pairs(Zones) do
	setElementData(el, "chat", true, false)
end


Phones = {}
PhonesTo = {}
PhonesWaiting = {}

function CallPhones(thePlayer, _, h)
    if(not Phones[thePlayer]) then
		if(h) then
			if(tostring(getElementData(thePlayer, "id")) ~= tostring(h)) then
				for key,thePlayers in pairs(getElementsByType "player") do
					if(tostring(getElementData(thePlayers, "id")) == tostring(h)) then
						if(not PhonesWaiting[thePlayers]) then
							CallIn(thePlayer)
							PhonesTo[thePlayer] = thePlayers
							PhonesWaiting[thePlayers] = thePlayer
							outputChatBox("Напиши /call чтобы бросить трубку", thePlayer, 255,255,255,true)
							outputChatBox("Напиши /call чтобы взять трубку", thePlayers, 255,255,255,true)
							triggerClientEvent(thePlayer, "PlaySFXSoundEvent", thePlayer, 12)
							triggerClientEvent(thePlayers, "PlaySFXSoundEvent", thePlayers, 13)
							return true
						else
							outputChatBox("* Абонент занят", thePlayer, 255,255,255,true)
							return true
						end
					end
				end
				outputChatBox("* "..h.." Номер не найден", thePlayer, 255,255,255,true)
			else
				outputChatBox("* Абонент занят", thePlayer, 255,255,255,true) -- сам себе
			end
		else
			if(PhonesWaiting[thePlayer]) then
				CallIn(thePlayer)
				outputChatBox("* Абонент взял трубку", PhonesWaiting[thePlayer], 255,255,255,true)
				PhonesTo[thePlayer] = PhonesWaiting[thePlayer]
			else
				outputChatBox("Используй /call id игрока чтобы позвонить", thePlayer, 255,255,255,true)
				outputChatBox("Напиши /call чтобы бросить трубку", thePlayer, 255,255,255,true)
			end
		end
	else
		CallOut(thePlayer)
		if(Phones[PhonesTo[thePlayer]]) then
			CallOut(PhonesTo[thePlayer])
			outputChatBox("* Абонент положил трубку", PhonesTo[thePlayer], 255,255,255,true)
		end
		if(PhonesWaiting[PhonesTo[thePlayer]]) then
			PhonesWaiting[PhonesTo[thePlayer]] = nil
		end
	end
end
addCommandHandler("call", CallPhones)


function CallIn(thePlayer)
	SetControls(thePlayer, "phone", {["fire"] = true, ["action"] = true, ["jump"] = true, ["sprint"] = true})

	StartAnimation(thePlayer, "ped", "phone_in", 1, false, true, true, true)
	Phones[thePlayer] = true
	AddPlayerArmas(thePlayer, 330)
end


function CallOut(thePlayer)
	SetControls(thePlayer, "phone", {["fire"] = false, ["action"] = false, ["jump"] = false, ["sprint"] = false})

	StartAnimation(thePlayer, "ped", "phone_out", 1, false, true, true, true)
	setTimer(function()
		RemovePlayerArmas(thePlayer, 330)
		Phones[thePlayer] = false
		PhonesTo[thePlayer] = false
		if(PhonesWaiting[thePlayer]) then
			PhonesWaiting[thePlayer] = nil
		end
	end, 2000, 1)
end



function CallPhoneOutput(thePlayer, arg)
	CallPhones(thePlayer, _, arg)
end
addEvent("CallPhoneOutput", true)
addEventHandler("CallPhoneOutput", root, CallPhoneOutput)





function CallPolice(Player)
	if(not Phones[source] and getElementHealth(source) > 20) then
		CallIn(source)
		setTimer(PhoneTalk, 1600, 1, source)
		setTimer(PhoneTalkEnd, 10000, 1, source, Player)
	end
end
addEvent("CallPolice", true)
addEventHandler("CallPolice", root, CallPolice)

function PhoneTalk(thePlayer)
	StartAnimation(thePlayer, "ped", "phone_talk", 1)
	local x,y,z = getElementPosition(thePlayer)
	triggerEvent("onPlayerChat", thePlayer, "Алло, полиция? Преступник в "..getZoneName(x, y, z), 1)
end


PoliceCallBandints = {}

function PhoneTalkEnd(thePlayer, bandit)
	CallOut(thePlayer)
	if(not isPedDead(thePlayer)) then
		local x,y,z = GetPlayerLocation(getPlayerFromName(bandit))
		if(PoliceCallBandints[bandit] ~= getZoneName(x,y,z)) then
			PoliceCallBandints[bandit] = getZoneName(x,y,z)
			local banditPlayer = getPlayerFromName(bandit)
			local x,y,z = GetPlayerLocation(banditPlayer)
			StartAnimation(thePlayer, "ped", "phone_out", false,false,false,false)
			Respect(thePlayer, "civilian", 1)
			Respect(thePlayer, "police", 1)
			Respect(thePlayer, "ugol", -1)
			MissionCompleted(thePlayer, "УВАЖЕНИЕ +", "ЗАКОНОПОСЛУШНОСТЬ")
			PoliceCallRemove(x,y,z,"Обнаружен преступник")
		else
			outputChatBox("Полиции уже известно о положении преступника.", thePlayer)
			StartAnimation(thePlayer, "ped", "phone_out", false,false,false,false)
		end
	end
end



function ResultGet(sum)
    --outputChatBox(sum)
end


function onPlayerChat(message, messageType, messagenovision)
	if(getElementData(source, "auth")) then
		if(string.len(message:gsub("%s+", "")) == 0) then
			cancelEvent()
			return false
		end

		local theVehicle = getPedOccupiedVehicle(source)
		if(theVehicle) then
			if(getElementModel(theVehicle) == 582) then
				local seat = getPedOccupiedVehicleSeat(source)
				if(seat == 2 or seat == 3) then
					cancelEvent()
					if(getElementModel(source) == 60) then
						outputChatBox("#FF0033Прямой эфир #CC9966(ведущий):#FFFFFF "..message, getRootElement(), 255,255,255,true)
					else
						outputChatBox("#FF0033Прямой эфир #CC9966(гость):#FFFFFF "..message, getRootElement(), 255,255,255,true)
					end
				end
			end
		end

		if messageType == 0 then
			if(Phones[source]) then
				local CallTo = PhonesTo[source]
				outputChatBox("(ТЕЛЕФОН) ["..getElementData(source, "id").."] "..getPlayerName(source)..": "..message, source,0,255,255, true)
				if(getPedOccupiedVehicle(source)) then
					StartAnimation(source, "ped", "phone_talk", false,false,false,false)
				else
					StartAnimation(source, "ped", "phone_talk", 1, false, true, true, true)
				end
	
				if(Phones[CallTo]) then
					outputChatBox("(ТЕЛЕФОН) ["..getElementData(source, "id").."] "..getPlayerName(source)..": "..message, CallTo,0,255,255, true)
				end
				cancelEvent()
				return true
			else
				if(not MainChat[source]) then
					local x, y, z = getElementPosition(source)
					for id, player in ipairs(getElementsByType("player")) do
						local x2, y2, z2 = getElementPosition(player)
						local dist = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
						if dist <= 20 then
							triggerClientEvent(player, "PlayerSayEvent", player, message, source)
							
							if(not messagenovision) then -- Для действий
								OutputChat(player, message, source)
								if(not help[source]) then
									triggerClientEvent(source, "ToolTip", source, "#CCCCCCCообщения видны в радиусе 20м\nОбщий чат доступен в зонах отдыха")
									help[source] = true
								end
							end
						end
					end
					cancelEvent()
					return true
				else
					local color = getElementData(source, "color")
					local team = getPlayerTeam(source)
		
					if(not messagenovision) then
						callRemote("http://109.227.228.4/engine/include/MTA/index.php", ResultGet, getPlayerName(source):gsub('#%x%x%x%x%x%x', ''), message, color)
						OutputMainChat(message, source)
					end
					cancelEvent()
					return true
				end
			end
		elseif(messageType == 1) then
			for key,thePlayers in pairs(getElementsByType "player") do
				triggerClientEvent(thePlayers, "PlayerActionEvent", thePlayers, message, source)
			end
			cancelEvent()
		elseif(messageType == 2) then
			cancelEvent()
			local hex = RGBToHex(getPlayerNametagColor(source))

			local team = getPlayerTeam(source)
			if not team then
				return outputChatBox("Ты не состоишь в команде!", source, 255, 255, 255, true)
			end

			local members = getPlayersInTeam(team) or {}
			for _, player in ipairs(members) do
				outputChatBox("* Рация"..hex.." "..getPlayerName(source)..": #FFFFFF"..message, player, 255, 255, 255, true)
			end
			for key,thePlayers in pairs(getElementsByType "player") do
				triggerClientEvent(thePlayers, "PlayerSayEvent", thePlayers, message, source)
			end
		end
	else
		outputChatBox("Авторизируйся чтобы написать сообщение", source,255,255,255,true)
		cancelEvent()
	end
end
addEvent("onPlayerChat", true)
addEvent("CliendSideonPlayerChat", true)
addEventHandler("onPlayerChat", getRootElement(), onPlayerChat)
addEventHandler("CliendSideonPlayerChat", getRootElement(), onPlayerChat)



function Chat_Enter(thePlayer, matchingDimension)
	if getElementType(thePlayer) == "player" then
		if(getElementData(source, "chat")) then
			MainChat[thePlayer] = true
			OutputChat(thePlayer, "ты зашел в зону общего чата", "Server")
			
			SendWebPlayer()
			callRemote("http://109.227.228.4/engine/include/MTA/get_online.php", ResultGet)
		end
	end
end
addEventHandler("onColShapeHit", getRootElement(), Chat_Enter)

function Chat_Exit(thePlayer, matchingDimension)
	if getElementType(thePlayer) == "player" then
		if(getElementData(source, "chat")) then
			MainChat[thePlayer] = false
			OutputChat(thePlayer, "ты покинул зону общего чата", "Server")
			SendWebPlayer()
			callRemote("http://109.227.228.4/engine/include/MTA/get_online.php", ResultGet)
		end
	end
end
addEventHandler("onColShapeLeave", getRootElement(), Chat_Exit)



function BurnChatMSG(name, message, nickcolor)
	OutputMainChat(message, name)
end
addEvent("BurnChatMSG", true)
addEventHandler("BurnChatMSG", getRootElement(), BurnChatMSG)




function SendWebPlayer()
	if(getServerPort() == 22003) then
		local webplay = ''
		for _, thePlayer in ipairs(getElementsByType("player")) do
			if(getElementData(thePlayer, "auth")) then
				if(MainChat[thePlayer]) then
					local color = getElementData(thePlayer, "color") or "#EEEEEE"
					webplay = webplay.."<span style=\"color:"..color..";\">"..getPlayerName(thePlayer)..'</span><br />'
				end
			end
		end
		callRemote("http://109.227.228.4/engine/include/MTA/online.php", ResultGet, webplay)
	end
end


function Start()
	for _, thePlayer in ipairs(getElementsByType("player")) do
		if(getElementData(thePlayer, "auth")) then
			for _,el in pairs(Zones) do
				if(isElementWithinColShape(thePlayer, el)) then
					MainChat[thePlayer] = true
				end
			end
		end
	end
	SendWebPlayer()
end
addEventHandler("onResourceStart", getResourceRootElement(), Start)


local Avatars = {}

function DownloadPhotoCompleted(responseData, errno, dat)
	if errno == 0 then
		triggerClientEvent(dat[1], "onClientGotImage", dat[1], dat[2], responseData)
		Avatars[dat[2]] = responseData
	end
end


function DownloadPhoto(responseData, errno, dat)
	if errno == 0 then
		fetchRemote("http://109.227.228.4/database/users/"..dat[2].."/photo/"..responseData, DownloadPhotoCompleted, "", false, dat)
	else
		fetchRemote("http://109.227.228.4/engine/images/no_photo.jpg", DownloadPhotoCompleted, "", false, dat)
	end
end


function CheckAvatar(thePlayer, theAvatar)
	if(not Avatars[theAvatar]) then
		fetchRemote("http://109.227.228.4/database/users/"..theAvatar.."/photo.txt", DownloadPhoto, "", false, {thePlayer, theAvatar})
	else
		triggerClientEvent(thePlayer, "onClientGotImage", thePlayer, theAvatar, Avatars[theAvatar])
	end
end
addEvent("CheckAvatar", true)
addEventHandler("CheckAvatar", getRootElement(), CheckAvatar)


function OutputChat(thePlayer, message, from)
	triggerClientEvent(thePlayer, "OutputChat", thePlayer, message, from)
end
addEvent("OutputChat", true)
addEventHandler("OutputChat", getRootElement(), OutputChat)




function OutputMainChat(message, from, forced)
	for _, thePlayer in pairs(getElementsByType "player") do
		if(MainChat[thePlayer] or forced) then
			triggerClientEvent(thePlayer, "OutputChat", thePlayer, message, from)
		end
	end
end
addEvent("OutputMainChat", true)
addEventHandler("OutputMainChat", getRootElement(), OutputMainChat)



function checkChange(theKey, oldValue, newValue)
	if(getElementType(source) == "player") then
		if(theKey == "auth") then
			Avatars[getPlayerName(source)] = nil
			SendWebPlayer()
		end
	end
end
addEventHandler("onElementDataChange", root, checkChange)


function CheckVoice(voice, voicebank)
	if(string.sub(voice, 0, 1) ~= "[") then
		callRemote("http://109.227.228.4/engine/include/MTA/govorilka.php", ResultGet, voice, voicebank)
	end
end
addEvent("CheckVoice", true)
addEventHandler("CheckVoice", getRootElement(), CheckVoice)


