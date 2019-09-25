local Chat = {}
local screenWidth, screenHeight = guiGetScreenSize()
local scale = (screenWidth/1920)+(screenHeight/1080)
local scalex = (screenWidth/1920)
local scaley = (screenHeight/1080)
local ChatAlpha = 255
local HiddenChatTimer = false
local Avatars = {}
local AvatarW, AvatarH = 55*scale, 25*scale
local input = false
local SpawnMessage = true
showChat(false)



local RenderQuality = 1
local RenderTargets = {
	["Chat"] = {false, 700*scale, 150*scale, true}, 
	["HelpMessage"] = {false, 500*scale, 100*scale, true, "DrawHelpHandler"}, 
}

for name, dat in pairs(RenderTargets) do
	dat[1] = dxCreateRenderTarget(dat[2], dat[3], dat[4])
end


function UpdateTargets()
	for name, dat in pairs(RenderTargets) do
		if(dat[1]) then
			destroyElement(dat[1])			
		end
		dat[1] = dxCreateRenderTarget(dat[2]*RenderQuality, dat[3]*RenderQuality, dat[4])
		if(dat[5]) then
			triggerEvent(dat[5], localPlayer)
		end
	end
end

function RenderQualityChecker(theKey, oldValue, newValue)
    if theKey == "RenderQuality" and source == root then
		if(newValue) then
			RenderQuality = tonumber(getElementData(root, "RenderQuality"))
		else
			RenderQuality = 1
		end
			
		UpdateTargets()
    end
end
addEventHandler("onClientElementDataChange", root, RenderQualityChecker)





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
	dxSetRenderTarget(RenderTargets["Chat"][1], true)
	dxSetBlendMode("modulate_add")
	
	local scale = scale*RenderQuality
	local x = RenderTargets["Chat"][2]*RenderQuality
	local y = RenderTargets["Chat"][3]*RenderQuality
	local AvatarW = AvatarW*RenderQuality
	local AvatarH = AvatarH*RenderQuality
			
	local count = 1
	local countsize = AvatarH
	local th = dxGetFontHeight(scale, "default-bold")
	for i = #Chat, #Chat-4, -1 do
		if(Chat[i]) then
			count = count+1
			local avasizex = AvatarW -- Пока идет загрузка аватарки
			local avasizey = AvatarH
			
			if(Avatars[Chat[i][2]]) then
				avasizex = Avatars[Chat[i][2]][1]*RenderQuality -- Когда загружена
				avasizey = Avatars[Chat[i][2]][2]*RenderQuality -- Когда загружена
				
				dxDrawImage((AvatarW-(avasizex)), y-countsize-avasizey, avasizex, avasizey, Avatars[Chat[i][2]][3])
			end
			dxDrawBorderedText(Chat[i][2]..": "..Chat[i][1], AvatarW+(5*scale),y-countsize-(avasizey/2)-(th/2), 0, 0, tocolor(255, 255, 255, 255), scale, "default-bold", "left", "top", false,false,false,true,not getElementData(root, "LowPCMode"))
			countsize = countsize+avasizey
		end
	end
	
	if(input) then
		dxDrawRectangle(0, y-(AvatarH), 400*scale, AvatarH-2, tocolor(0, 0, 0, 150))
		dxDrawBorderedText("Сказать: "..input, 5*scale, y-(AvatarH/2)-(th/2), 0, 0, tocolor(255, 255, 255, 255), scale, "default-bold", "left", "top", false,false,false,true,not getElementData(root, "LowPCMode"))
	end
	
	dxSetBlendMode("blend")
	dxSetRenderTarget()
	return RenderTargets["Chat"][1]
end



function avatardraw()
	dxDrawImage(550*scalex, 580*scaley, RenderTargets["Chat"][2], RenderTargets["Chat"][3], DrawChat(), 0, 0, 0, tocolor(255, 255, 255, ChatAlpha))
	
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
	outputChatBox(from..": "..message)
	ChatAlpha = 255
	
	if(HiddenChatTimer) then
		resetTimer(HiddenChatTimer)
	else
		if(not isEventHandlerAdded("onClientHUDRender", root, avatardraw)) then
			addEventHandler("onClientHUDRender", root, avatardraw)
		end
		HiddenChatTimer = setTimer(function() HiddenChatTimer = false end, 3000, 1)
	end
	
	if(not Avatars[from]) then
		triggerServerEvent("CheckAvatar", localPlayer, localPlayer, from)
	end
end
addEvent("OutputChat", true)
addEventHandler("OutputChat", getRootElement(), OutputChat)




function call(command, id)
	triggerServerEvent("call", localPlayer, localPlayer, command, id)
end
addCommandHandler("call", call)


function el()
	triggerServerEvent("el", localPlayer, localPlayer)
end
addCommandHandler("el", el)


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
				dxDrawText(textb, left + oX, top + oY, right + oX, bottom + oY, tocolor(r, g, b, bitExtract(color, 24, 8)), scale, font, alignX, alignY, clip, wordBreak,postGUI, not getElementData(root, "LowPCMode"))
			end
		end

		dxDrawText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, not getElementData(root, "LowPCMode"))
	end
end

function string.explode(self, separator)
    if (#self == 0) then return {} end
    if (#separator == 0) then return { self } end

    return loadstring("return {\""..self:gsub(separator, "\",\"").."\"}")()
end


function PlaySound(link) 
	local s = playSound(link)

end
addEvent("PlaySound", true)
addEventHandler("PlaySound", localPlayer, PlaySound)



local RemoveInputTimer = setTimer(function()
	if getKeyState("backspace") == true then
		if(input) then
			input = utf8.remove(input, -1, -1)
		end
	end
end, 100, 0)

function playerPressedKey(button, press)
    if (press) then
        if(button == "escape") then
			openinput()
		elseif(button == "enter" or button == "num_enter") then
			if(utf8.sub(input, 1, 1) == "/") then
				local text = utf8.remove(input, 0, 1)
				
				local tables = string.explode(text, " ")
				
				if(tables[1] == "sms" or tables[1] == "pm") then
					if(tables[4]) then
						for i = 4, #tables do
							tables[3] = tables[3].." "..tables[i]
						end
					end
					triggerServerEvent("sms", localPlayer, localPlayer, tables[2], tables[3])
				else
					executeCommandHandler(unpack(tables))
				end
			else
				triggerServerEvent("CliendSideonPlayerChat", localPlayer, input, 0)
			end
			openinput()
		elseif(button == "backspace") then
			resetTimer(RemoveInputTimer)
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














local StaminaBarW, StaminaBarH = 85, 2

function getMaxStamina()
	return 5+math.floor(getPedStat(localPlayer, 22)/40)
end

local Stamina = false
local LVLUPSTAMINA = 10
local ShakeLVL = 0
local PlayersAction = {}
local timersAction = {}




function checkKey()
	if(getPedControlState(localPlayer, "sprint")) and Stamina ~= 0 then
		Stamina = Stamina-0.1
		if(getPedStat(localPlayer, 22) ~= 1000) then
			LVLUPSTAMINA = LVLUPSTAMINA-0.1
			if(LVLUPSTAMINA == 0) then
				triggerServerEvent("StaminaOut", localPlayer, true)
				LVLUPSTAMINA = 10
			end
		end
	end
	if(Stamina <= 0) then
		triggerServerEvent("StaminaOut", localPlayer)
		setPedControlState(localPlayer, "sprint", false)
	end
end





function PlayerSpawn()
	if(not Stamina) then
		setTimer(checkKey,100,0)
		setTimer(updateStamina,250,0)
		addEventHandler("onClientRender", root, DrawStaminaBar)
	end
	Stamina = getMaxStamina()
end
addEventHandler("onClientPlayerSpawn", getLocalPlayer(), PlayerSpawn)

function Start()
	UpdateTargets()
	if(not isPedDead(localPlayer)) then
		PlayerSpawn()
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), Start)



function DrawStaminaBar()
	local cx,cy,cz = getCameraMatrix()
	for _, thePlayer in pairs(getElementsByType("player", getRootElement(), true)) do
		local x,y,z = getPedBonePosition(thePlayer, 8)
		local sx,sy = getScreenFromWorldPosition(x,y,z+0.3)
		if(sx and sy) then
			local dist = getDistanceBetweenPoints3D(x,y,z,cx,cy,cz)
			local alpha = 255-(dist*5)
			if(alpha >= 0) then
				if(not RenderTargets[thePlayer]) then
					RenderTargets[thePlayer] = {false, 400, 60, true}
				end
				dxDrawImage(sx-((RenderTargets[thePlayer][2])/2),sy-((RenderTargets[thePlayer][3])/2), RenderTargets[thePlayer][2], RenderTargets[thePlayer][3], DrawNicknameBar(thePlayer), 0, 0, 0, tocolor(255,255,255,alpha), true)
			end
		end
	end
	
	for _, thePlayer in pairs(getElementsByType("ped", getRootElement(), true)) do
		local x,y,z = getPedBonePosition(thePlayer, 8)
		local sx,sy = getScreenFromWorldPosition(x,y,z+0.3)
		if(sx and sy) then
			local dist = getDistanceBetweenPoints3D(x,y,z,cx,cy,cz)
			local alpha = 255-(dist*5)
			if(alpha >= 0) then
				if(not RenderTargets[thePlayer]) then
					RenderTargets[thePlayer] = {false, 400, 60, true}
				end
				dxDrawImage(sx-((RenderTargets[thePlayer][2])/2),sy-((RenderTargets[thePlayer][3])/2), RenderTargets[thePlayer][2], RenderTargets[thePlayer][3], DrawNicknameBar(thePlayer), 0, 0, 0, tocolor(255,255,255,alpha), true)
			end
		end
	end
end






function PlayerActionEvent(message,thePlayer)
	PlayersAction[thePlayer] = message
	if(isTimer(timersAction[thePlayer])) then
		killTimer(timersAction[thePlayer])
	end
	timersAction[thePlayer] = setTimer(function()
		PlayersAction[thePlayer] = nil
	end, 300+(#message*150), 1)
end
addEvent("PlayerActionEvent", true)
addEventHandler("PlayerActionEvent", localPlayer, PlayerActionEvent)




function DrawNicknameBar(thePlayer)
	if(not RenderTargets[thePlayer][1]) then
		RenderTargets[thePlayer][1] = dxCreateRenderTarget(RenderTargets[thePlayer][2], RenderTargets[thePlayer][3], RenderTargets[thePlayer][4])
	end
	
	local scale = scale*RenderQuality
	local x = RenderTargets[thePlayer][2]*RenderQuality
	local y = RenderTargets[thePlayer][3]*RenderQuality
	
	dxSetRenderTarget(RenderTargets[thePlayer][1], true)
	dxSetBlendMode("modulate_add")
	
	if(PlayersAction[thePlayer]) then			
		dxDrawText(PlayersAction[thePlayer], x,y/6, 2,2, tocolor(0,0,0,255), scale, "default-bold", "center", "top", false,false,false,true,not getElementData(root, "LowPCMode"))
		dxDrawText(PlayersAction[thePlayer], x,y/6, 0,0, tocolor(255,255,255,255), scale, "default-bold", "center", "top", false,false,false,true,not getElementData(root, "LowPCMode"))
	end
	
	if(getElementType(thePlayer) == "player") then
		local StaminaBarW, StaminaBarH = StaminaBarW*RenderQuality, StaminaBarH*RenderQuality
		dxDrawText(getPlayerName(thePlayer).."("..getElementData(thePlayer, "id")..")", x,y/2, 2,2, tocolor(0,0,0,255), scale, "default-bold", "center", "top", false,false,false,true,not getElementData(root, "LowPCMode"))
		dxDrawText(getPlayerName(thePlayer).."("..getElementData(thePlayer, "id")..")", x,y/2, 0,0, tocolor(255,255,255,255), scale, "default-bold", "center", "top", false,false,false,true,not getElementData(root, "LowPCMode"))
		if(thePlayer == localPlayer) then
			dxDrawRectangle((x/2)-(StaminaBarW/2),y-(3*scale), StaminaBarW, StaminaBarH, tocolor(50,50,50, 50), false)
			dxDrawRectangle((x/2),y-(3*scale), ((Stamina/getMaxStamina())*getMaxStamina()*(StaminaBarW/10)), StaminaBarH, tocolor(150,200,0, 150), false)
			dxDrawRectangle((x/2),y-(3*scale), -((Stamina/getMaxStamina())*getMaxStamina()*(StaminaBarW/10)), StaminaBarH, tocolor(150,200,0, 150), false)
		end
	end
	
	dxSetBlendMode("blend")
	dxSetRenderTarget()
	return RenderTargets[thePlayer][1]
end


function updateStamina()
	if Stamina ~= getMaxStamina() and getPedControlState(localPlayer, "sprint") == false then
		Stamina = Stamina+0.1
	end
	
	if(ShakeLVL > 0) then
		ShakeLVL = ShakeLVL-1
		setCameraShakeLevel(ShakeLVL)
	end	
end



function ShakeLevel(level)
	ShakeLVL = ShakeLVL+level
end
addEvent("ShakeLevel", true)
addEventHandler("ShakeLevel", localPlayer, ShakeLevel)










local MessageTimer = false


function DrawHelpMessage()
	dxDrawImage(screenWidth/2-(RenderTargets["HelpMessage"][2]/2), screenHeight/1.2, RenderTargets["HelpMessage"][2], RenderTargets["HelpMessage"][3], RenderTargets["HelpMessage"][1])
end

function helpmessage(message)
	DrawHelp(message)
	
	if(isTimer(MessageTimer)) then
		killTimer(MessageTimer)
	else
		addEventHandler("onClientRender", root, DrawHelpMessage)
	end
	
	MessageTimer = setTimer(function()
		removeEventHandler("onClientRender", root, DrawHelpMessage)
	end, 3500, 1)
end
addEvent("helpmessageEvent", true)
addEventHandler("helpmessageEvent", root, helpmessage)


function DrawHelp(message)
	dxSetRenderTarget(RenderTargets["HelpMessage"][1], true)
	dxSetBlendMode("modulate_add")
	
	local scale = scale*RenderQuality
	local x = RenderTargets["HelpMessage"][2]*RenderQuality
	local y = RenderTargets["HelpMessage"][3]*RenderQuality
	
	dxDrawBorderedText(message or "", x, 0, 0, 0, tocolor(255, 255, 255, 255), scale*1.2, "sans", "center", "top", false,false,false,true,not getElementData(root, "LowPCMode"))
	
	dxSetBlendMode("blend")
	dxSetRenderTarget()
	return RenderTargets["HelpMessage"][1]
end
addEvent("DrawHelpHandler", true)
addEventHandler("DrawHelpHandler", root, DrawHelp)








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
