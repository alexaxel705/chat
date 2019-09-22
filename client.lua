local Chat = {}
local screenWidth, screenHeight = guiGetScreenSize()
local scale = (screenWidth/1920)+(screenHeight/1080)
local scalex = (screenWidth/1920)
local scaley = (screenHeight/1080)
local ChatW, ChatH = 700*scale, 150*scale
local ChatImage = dxCreateRenderTarget(ChatW, ChatH, true)
local ChatAlpha = 255
local HiddenChatTimer = false
local Avatars = {}
local AvatarW, AvatarH = 55*scale, 25*scale
local input = false
local SpawnMessage = true
showChat(false)



function onClientGotImage(thePlayer, Avatar)
	if(isElement(thePlayer)) then
		thePlayer = getPlayerName(thePlayer)
	end
	
	local image = dxCreateTexture(Avatar)
	local w,h = dxGetMaterialSize(image)
	
	local maxn = 0
	local maxi = 0
	if(w/AvatarW >= h/AvatarH) then
		maxn = AvatarW
		maxi = w
	else
		maxn = AvatarH
		maxi = h
	end
	
	local sizea, sizeb = maxi/maxn, maxi/maxn
		
	
	Avatars[thePlayer] = {w/sizea, h/sizeb, image}
	
end
addEvent("onClientGotImage", true)
addEventHandler("onClientGotImage", getRootElement(), onClientGotImage)



function DrawChat()
	dxSetRenderTarget(ChatImage, true)
	dxSetBlendMode("modulate_add")
	
	local count = 1
	local countsize = AvatarH
	local th = dxGetFontHeight(scale, "default-bold")
	for i = #Chat, #Chat-4, -1 do
		if(Chat[i]) then
			count = count+1
			local avasize = AvatarH -- Пока идет загрузка аватарки
			
			if(Avatars[Chat[i][2]]) then
				avasize = Avatars[Chat[i][2]][2]
				dxDrawImage((AvatarW-(Avatars[Chat[i][2]][1])), ChatH-countsize-avasize, Avatars[Chat[i][2]][1], Avatars[Chat[i][2]][2], Avatars[Chat[i][2]][3])
			end
			dxDrawBorderedText(Chat[i][2]..": "..Chat[i][1], AvatarW+(5*scale), ChatH-countsize-(avasize/2)-(th/2), 0, 0, tocolor(255, 255, 255, 255), scale, "default-bold", "left", "top", false, false, false, true)
			
			countsize = countsize+avasize
		end
	end
	
	if(input) then
		dxDrawRectangle(0, ChatH-(AvatarH), 400*scale, AvatarH-2, tocolor(0, 0, 0, 150))
		dxDrawBorderedText("Сказать: "..input, 5*scale, ChatH-(AvatarH/2)-(th/2), 0, 0, tocolor(255, 255, 255, 255), scale, "default-bold", "left", "top", false, false, false, true)
	end
	
	dxSetBlendMode("blend")
	dxSetRenderTarget()
	return ChatImage
end



function avatardraw()
	dxDrawImage(550*scalex, 580*scaley, ChatW, ChatH, DrawChat(), 0, 0, 0, tocolor(255, 255, 255, ChatAlpha))
	
	if(not HiddenChatTimer and not input) then
		ChatAlpha = ChatAlpha-2
		if(ChatAlpha <= 0) then
			Chat = {}
			removeEventHandler("onClientHUDRender", root, avatardraw)
		end
	end
end

function OutputChat(message, from)
	if(isElement(from)) then
		from = getPlayerName(from)
	end
	Chat[#Chat+1] = {message, from}
	outputConsole(from..": "..message)
	ChatAlpha = 255
	
	
	if(HiddenChatTimer) then
		resetTimer(HiddenChatTimer)
	else
		if(not isEventHandlerAdded("onClientHUDRender", root, avatardraw)) then
			addEventHandler("onClientHUDRender", root, avatardraw)
		end
		HiddenChatTimer = setTimer(function() HiddenChatTimer = false end, 2000, 1)
	end
	
	if(not Avatars[from]) then
		triggerServerEvent("CheckAvatar", localPlayer, localPlayer, from)
	end
end
addEvent("OutputChat", true)
addEventHandler("OutputChat", getRootElement(), OutputChat)




function call(_, id)
	triggerServerEvent("call", localPlayer, localPlayer, _, id)
end
addCommandHandler("call", call)




function math.round(number, decimals, method)
    decimals = decimals or 0
    local factor = 10 ^ decimals
    if (method == "ceil" or method == "floor") then return math[method](number * factor) / factor
    else return tonumber(("%."..decimals.."f"):format(number)) end
end


function dxDrawBorderedText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, subPixelPositioning)
	if(text) then
		local r,g,b = bitExtract(color, 0, 8), bitExtract(color, 8, 8), bitExtract(color, 16, 8)
		if(r+g+b >= 100) then r = 0 g = 0 b = 0 else r = 255 g = 255 b = 255 end
		local textb = string.gsub(text, "#%x%x%x%x%x%x", "")
		local locsca = math.round(scale, 0)
		if (locsca == 0) then locsca = 1 end
		for oX = -locsca, locsca do 
			for oY = -locsca, locsca do 
				dxDrawText(textb, left + oX, top + oY, right + oX, bottom + oY, tocolor(r, g, b, bitExtract(color, 24, 8)), scale, font, alignX, alignY, clip, wordBreak,postGUI,false)
			end
		end

		dxDrawText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, true)
	end
end

function playerPressedKey(button, press)
    if (press) then
        if(button == "escape") then
			openinput()
		elseif(button == "enter" or button == "num_enter") then
			if(utf8.sub(input, 1, 1) == "/") then
				executeCommandHandler(unpack(split(utf8.remove(input, 0, 1), ' ')))
			else
				triggerServerEvent("CliendSideonPlayerChat", localPlayer, input, 0)
			end
			openinput()
		elseif(button == "backspace") then
			input = utf8.remove(input, -1, -1)
		end
		cancelEvent()
    end
end

function outputPressedCharacter(character)
	if(input == false) then 
		input = ""
		if(not isEventHandlerAdded("onClientHUDRender", root, avatardraw)) then
			addEventHandler("onClientHUDRender", root, avatardraw)
		end
		return true
	end
	
	input = input..character
end


function openinput()
	ChatAlpha = 255
	if(input) then
		input = false
		removeEventHandler("onClientCharacter", getRootElement(), outputPressedCharacter)
		removeEventHandler("onClientKey", root, playerPressedKey)
		bindKey("t", "down", openinput)
	else		
		input = false
		addEventHandler("onClientCharacter", getRootElement(), outputPressedCharacter)
		addEventHandler("onClientKey", root, playerPressedKey)
		unbindKey("t", "down", openinput)
	end
end
bindKey("t", "down", openinput)





function Spawn()
	if(SpawnMessage) then
		OutputChat("Используй клавишу T чтобы писать в чат", "Server")
		SpawnMessage = false
	end
end
addEventHandler("onClientPlayerSpawn", getLocalPlayer(), Spawn)




function remotePlayerJoin()
	Avatars[getPlayerName(source)] = nil
end
addEventHandler("onClientPlayerJoin", getRootElement(), remotePlayerJoin)





function isEventHandlerAdded(sEventName, pElementAttachedTo, func)
	if 
		type(sEventName) == 'string' and 
		isElement(pElementAttachedTo) and 
		type(func) == 'function' 
	then
		local aAttachedFunctions = getEventHandlers( sEventName, pElementAttachedTo )
		if type(aAttachedFunctions) == 'table' and #aAttachedFunctions > 0 then
			for i, v in ipairs( aAttachedFunctions ) do
				if v == func then
					return true
				end
			end
		end
	end
	return false
end
