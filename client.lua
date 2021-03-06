﻿local Chat = {}
local screenWidth, screenHeight = guiGetScreenSize()
local scale = (screenWidth/1920)+(screenHeight/1080)
local scalex = (screenWidth/1920)
local scaley = (screenHeight/1080)
local ChatAlpha = 255
local HiddenChatTimer = false
local Avatars = {}
local AvatarW, AvatarH = 55*scale, 25*scale
local input = false
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
    if theKey == "RenderQuality" and source == localPlayer then
		if(newValue) then
			RenderQuality = tonumber(getElementData(localPlayer, "RenderQuality"))
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
			dxDrawBorderedText(Chat[i][2]..": "..Chat[i][1], AvatarW+(5*scale),y-countsize-(avasizey/2)-(th/2), 0, 0, tocolor(255, 255, 255, 255), scale, "default-bold", "left", "top", false,false,false,true,not getElementData(localPlayer, "LowPCMode"))
			countsize = countsize+avasizey
		end
	end
	
	if(input) then
		dxDrawRectangle(0, y-(AvatarH), 400*scale, AvatarH-2, tocolor(0, 0, 0, 150))
		dxDrawBorderedText("Сказать: "..input, 5*scale, y-(AvatarH/2)-(th/2), 0, 0, tocolor(255, 255, 255, 255), scale, "default-bold", "left", "top", false,false,false,true,not getElementData(localPlayer, "LowPCMode"))
	end
	
	dxSetBlendMode("blend")
	dxSetRenderTarget()
	return RenderTargets["Chat"][1]
end



function avatardraw()
	if(not isChatVisible()) then
		dxDrawImage(550*scalex, 580*scaley, RenderTargets["Chat"][2], RenderTargets["Chat"][3], DrawChat(), 0, 0, 0, tocolor(255, 255, 255, ChatAlpha))
	end
	
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





function helpcmd(thePlayer)
	triggerEvent("ToolTip", localPlayer, "/piss - обоссать, /wank - подрочить\r\n"..
	"/dance [1-13] - танцевать, /arm - служить в армии\r\n"..
	"/teamleave - покинуть фракцию\r\n")
end
addCommandHandler("cmd", helpcmd)
addCommandHandler("help", helpcmd)



function Execute(command, dat)
	triggerServerEvent(command, localPlayer, localPlayer, dat)
end
addCommandHandler("call", Execute)
addCommandHandler("el", Execute)
addCommandHandler("piss", Execute)
addCommandHandler("race", Execute)
addCommandHandler("wank", Execute)
addCommandHandler("kill", Execute)
addCommandHandler("dm", Execute)
addCommandHandler("tp", Execute)
addCommandHandler("dance", Execute)
addCommandHandler("arm", Execute)





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
				dxDrawText(textb, left + oX, top + oY, right + oX, bottom + oY, tocolor(r, g, b, bitExtract(color, 24, 8)), scale, font, alignX, alignY, clip, wordBreak,postGUI, not getElementData(localPlayer, "LowPCMode"))
			end
		end

		dxDrawText(text, left, top, right, bottom, color, scale, font, alignX, alignY, clip, wordBreak, postGUI, colorCoded, not getElementData(localPlayer, "LowPCMode"))
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
	if(getElementData(localPlayer, "auth") and not isChatVisible()) then
		ChatAlpha = 255
		if(input) then
			input = false
			setElementData(localPlayer, "chat", false)
			removeEventHandler("onClientCharacter", getRootElement(), outputPressedCharacter)
			removeEventHandler("onClientKey", root, playerPressedKey)
			bindKey("t", "down", openinput)
		else		
			input = false
			setElementData(localPlayer, "chat", true)
			addEventHandler("onClientCharacter", getRootElement(), outputPressedCharacter)
			addEventHandler("onClientKey", root, playerPressedKey)
			unbindKey("t", "down", openinput)
		end
	end
end
bindKey("t", "down", openinput)






function remotePlayerJoin()
	Avatars[getPlayerName(source)] = nil
end
addEventHandler("onClientPlayerJoin", getRootElement(), remotePlayerJoin)






local StaminaBarW, StaminaBarH = 85*scale, 2*scale

function getMaxStamina()
	return 5+math.floor(getPedStat(localPlayer, 22)/40)
end

local Stamina = false
local ShakeLVL = 0
setCameraShakeLevel(0)
local PlayersAction = {}
local timersAction = {}




function checkKey()
	if(getPedControlState(localPlayer, "sprint")) and Stamina ~= 0 then
		Stamina = Stamina-0.1
	end
	if(Stamina <= 0) then
		setPedControlState(localPlayer, "sprint", false)
	end
end





function PlayerSpawn()
	if(not Stamina) then
		setTimer(checkKey,100,0)
		setTimer(updateStamina,250,0)
		addEventHandler("onClientHUDRender", root, DrawStaminaBar)
	end
	Stamina = getMaxStamina()
end
addEventHandler("onClientPlayerSpawn", getLocalPlayer(), PlayerSpawn)


function Start()
	UpdateTargets()
	if(getElementData(localPlayer, "auth")) then
		PlayerSpawn()
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), Start)



function DrawStaminaBar()
	if(not getElementData(localPlayer, "HUD")) then return false end
	
	local cx,cy,cz = getCameraMatrix()
	for _, thePlayer in pairs(getElementsByType("player", getRootElement(), true)) do
		local x,y,z = getPedBonePosition(thePlayer, 8)
		local sx,sy = getScreenFromWorldPosition(x,y,z+0.3)
		if(sx and sy) then
			local dist = getDistanceBetweenPoints3D(x,y,z,cx,cy,cz)
			local alpha = 255-(dist*5)
			if(alpha >= 0) then
				if(not RenderTargets[thePlayer]) then
					RenderTargets[thePlayer] = {false, 800, 70, true}
				end
				dxDrawImage(sx-((RenderTargets[thePlayer][2])/2),sy-((RenderTargets[thePlayer][3])/2), RenderTargets[thePlayer][2], RenderTargets[thePlayer][3], DrawNicknameBar(thePlayer), 0, 0, 0, tocolor(255,255,255,alpha))
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
				dxDrawImage(sx-((RenderTargets[thePlayer][2])/2),sy-((RenderTargets[thePlayer][3])/2), RenderTargets[thePlayer][2], RenderTargets[thePlayer][3], DrawNicknameBar(thePlayer), 0, 0, 0, tocolor(255,255,255,alpha))
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
	
	dxSetRenderTarget(RenderTargets[thePlayer][1], true)
	dxSetBlendMode("modulate_add")
	
	local scale = scale*RenderQuality
	local x = RenderTargets[thePlayer][2]*RenderQuality
	local y = RenderTargets[thePlayer][3]*RenderQuality
	
	local fh = dxGetFontHeight(scale, "default-bold")
	
	local CountLine = 1
	
	if(getElementType(thePlayer) == "player") then
		local StaminaBarW, StaminaBarH = StaminaBarW*RenderQuality, StaminaBarH*RenderQuality
		
		local Rang = ""
		local id = ""
		if(getKeyState("lalt")) then
			CountLine = 2
			local Zvanie = exports["228"]:GetSkinJob(getElementModel(thePlayer))
			id = " ("..getElementData(thePlayer, "id")..")"
			Rang = "\r\n#9E9E9E"..utf8.lower(Zvanie)..""
		end
		dxDrawText("#FFFFFF"..getPlayerName(thePlayer)..id..Rang, x,y-(StaminaBarH*3)-fh*CountLine, 2,2, tocolor(0,0,0,255), scale, "default-bold", "center", "top", false,false,false,true,not getElementData(localPlayer, "LowPCMode"))
		dxDrawText("#FFFFFF"..getPlayerName(thePlayer)..id..Rang, x,y-(StaminaBarH*3)-fh*CountLine, 0,0, tocolor(255,255,255,255), scale, "default-bold", "center", "top", false,false,false,true,not getElementData(localPlayer, "LowPCMode"))
		CountLine = CountLine+1
		if(thePlayer == localPlayer) then
			local theVehicle = getPedOccupiedVehicle(thePlayer)
			if(theVehicle) then
				local ragecolor = tocolor(255,200,40,200)
				local nitro = getVehicleUpgradeOnSlot(theVehicle, 8)-1007
				if(nitro > 0) then
					ragecolor = tocolor(40,200,255,155+(25*nitro))
				end
			
				dxDrawRectangle((x/2)-(StaminaBarW/2),y-(StaminaBarH*2), StaminaBarW, StaminaBarH, tocolor(50,50,50, 50), false)
				dxDrawRectangle((x/2),y-(StaminaBarH*2), ((getElementData(localPlayer, "Rage")/1000)*(StaminaBarW/2)), StaminaBarH, ragecolor, false)
				dxDrawRectangle((x/2),y-(StaminaBarH*2), -((getElementData(localPlayer, "Rage")/1000)*(StaminaBarW/2)), StaminaBarH, ragecolor, false)
			else
				dxDrawRectangle((x/2)-(StaminaBarW/2),y-(StaminaBarH*2), StaminaBarW, StaminaBarH, tocolor(50,50,50, 50), false)
				dxDrawRectangle((x/2),y-(StaminaBarH*2), ((Stamina/getMaxStamina())*1000)*(StaminaBarW/2000), StaminaBarH, tocolor(150,200,0, 150), false)
				dxDrawRectangle((x/2),y-(StaminaBarH*2), -((Stamina/getMaxStamina())*1000)*(StaminaBarW/2000), StaminaBarH, tocolor(150,200,0, 150), false)
			end
		end
	end
	
	if(PlayersAction[thePlayer]) then			
		dxDrawText(PlayersAction[thePlayer], x,y-(StaminaBarH*3)-(fh*(CountLine)), 2,2, tocolor(0,0,0,255), scale, "default-bold", "center", "top", false,false,false,true,not getElementData(localPlayer, "LowPCMode"))
		dxDrawText(PlayersAction[thePlayer], x,y-(StaminaBarH*3)-(fh*(CountLine)), 0,0, tocolor(255,255,255,255), scale, "default-bold", "center", "top", false,false,false,true,not getElementData(localPlayer, "LowPCMode"))
	end
	
	dxSetBlendMode("blend")
	dxSetRenderTarget()
	return RenderTargets[thePlayer][1]
end


function updateStamina()
	if Stamina <= getMaxStamina() and getPedControlState(localPlayer, "sprint") == false then
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

local helpMSG = ""
function helpmessage(message)
	helpMSG = message
	DrawHelp()
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


function DrawHelp()
	dxSetRenderTarget(RenderTargets["HelpMessage"][1], true)
	dxSetBlendMode("modulate_add")
	
	local scale = scale*RenderQuality
	local x = RenderTargets["HelpMessage"][2]*RenderQuality
	local y = RenderTargets["HelpMessage"][3]*RenderQuality
	
	dxDrawBorderedText(helpMSG, x, 0, 0, 0, tocolor(255, 255, 255, 255), scale*1.2, "sans", "center", "top", false,false,false,true,not getElementData(localPlayer, "LowPCMode"))
	
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
