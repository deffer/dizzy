Dizzy = Dizzy or {}

Dizzy.show=function()
	if Dizzy.DebugFrame and not Dizzy.DebugFrame:IsVisible() then Dizzy.DebugFrame:Show() end
end

Dizzy.hide=function()
	if Dizzy.DebugFrame and Dizzy.DebugFrame:IsVisible() then Dizzy.DebugFrame:Hide() end
end

Dizzy.CacheItem = function(ilink)
	local name, link,
	iQuality, iLevel, reqLevel,
	iclass, isubclass,
	maxStack, equipSlot, texture, vendorPrice = GetItemInfo(ilink)
	Dizzy.LastSeen = {Name = name, Link = link, 
		Class = iclass, SubClass = isubclass, 
		Quality=iQuality, ItemLevel = iLevel, ReqLevel = reqLevel,
		IsDizzy = Dizzy.IsDizzy(iclass, isubclass, iQuality)}
end

Dizzy.UpdateFrameEP = function(item, frame)
	-- |cffffff00(bright yellow)|r, |cff0070dd(rare item blue)|r, |cff40c040(easy quest green)|r
	local userEP = Dizzy.GetEpOfUserLevel(item.ReqLevel)
	local itemEP, sure = Dizzy.GetEpOfItemLevel(item.ItemLevel, item.Quality, item.Class)
	local r,g,b = 0,0,0
	if (not userEP) then
		r,g,b = 0x40, 0x40, 0x40
	else
		if itemEP <= userEP then
			r,g,b = 0x40, 0xc0, 0x40
		else
			r,g,b = 0xff, 0xff, 0x00
		end
	end
	local itemEpStr = Dizzy.GetExpansionShortName(itemEP)
	if (not sure) then
		itemEpStr = itemEpStr.."(?)"
	end
	itemEpStr = itemEpStr.." "..tostring(itemEP).." > "..tostring(userEP).." ("..item.ItemLevel..","..item.Quality..","..item.Class..")"

	frame:AddLine(itemEpStr, r, g, b, true)
	frame:Show()
end

Dizzy.GetID = function(ilink)
	local _,_,iid = strfind(ilink,"|Hitem:(%d+):")
	return tonumber(iid)
end

Dizzy.DebugShowItem = function()
	if GameTooltip:IsVisible() then		
		local name, link = GameTooltip:GetItem()
		local iname, ilink,
			quality, iLevel, reqLevel,
			iclass, isubclass,
			maxStack, equipSlot, texture, vendorPrice = GetItemInfo(link)
		local itemid = Dizzy.GetID(link)
		Dizzy.Debug(ilink.." - "..itemid)
		local dizFlag = Dizzy.IsDizzy(iclass, isubclass,quality) and "DE" or "non-DE"
		local str = ""..iclass.." ("..tostring(isubclass)..") quality "..quality..", price "..vendorPrice..", "..dizFlag
		Dizzy.Debug(str)

		local userEP = Dizzy.GetEpOfUserLevel(reqLevel)
		local itemEP, sure = Dizzy.GetEpOfItemLevel(iLevel, quality, iclass)
		str = "Item from expansion "..Dizzy.GetExpansionShortName(itemEP).."("..tostring(itemEP)..")"
		str = str.." wearable in "..Dizzy.GetExpansionShortName(userEP).."("..tostring(userEP)..")"
		Dizzy.Debug(str)
	else
	    Dizzy.Debug("GameTooltip frame is not visible")
	end		
end

Dizzy.HookOntoTooltipFrame = function()
	if(GameTooltip:GetScript("OnTooltipSetItem")) then
		GameTooltip:HookScript("OnTooltipSetItem",Dizzy.ScriptOnTooltipSetItem);
	else
		GameTooltip:SetScript("OnTooltipSetItem",Dizzy.ScriptOnTooltipSetItem);
	end
	if(ItemRefTooltip:GetScript("OnTooltipSetItem")) then
		ItemRefTooltip:HookScript("OnTooltipSetItem",Dizzy.ScriptOnTooltipSetItem);
	else
		ItemRefTooltip:SetScript("OnTooltipSetItem",Dizzy.ScriptOnTooltipSetItem);
	end
	if(GameTooltip:GetScript("OnHide")) then
		GameTooltip:HookScript("OnHide",Dizzy.ScriptOnTooltipHide);
	else
		GameTooltip:SetScript("OnHide",Dizzy.ScriptOnTooltipHide);
	end	
end

Dizzy.ScriptOnTooltipHide = function (this)
	-- may want to clear cache (Dizzy.LastSeen)
end

Dizzy.ScriptOnTooltipSetItem = function(frame)
	local iname,ilink = frame:GetItem();
	local windowsName = frame:GetName()

	if ((not Dizzy.LastSeen) or not (Dizzy.LastSeen.Link == ilink)) then
		Dizzy.CacheItem(ilink)
	end

	if Dizzy.LastSeen then
		local item = Dizzy.LastSeen
		if item.IsDizzy then
			Dizzy.UpdateFrameEP(item, frame)
		elseif item.OfTillersInterest then
			Dizzy.UpdateFrameTillers(item, frame)
		end
	else
		Dizzy.Debug("Nothing in cache for : "..ilink)
		DEFAULT_CHAT_FRAME:AddMessage("Nothing in cache for : "..ilink) -- TODO remove
	end
end

 
SLASH_DIZZY1 = "/dizzy"
SLASH_DIZZY2 = "/dz"
local function SlashHandler(msg, editbox)
	-- Any leading non-whitespace is captured into command, the rest (minus leading whitespace) is captured into rest
	local command, rest = msg:match("^(%S*)%s*(.-)$")
	if command == "show" or command=="hide" then
		Dizzy[command]()
	elseif command == "help" then
		print("Syntax: /dz (frames|item|glob) to dump corresponding info into debug frame")
		print("Syntax: /dz (show|hide) to show or hide debug frame")
	elseif command == frames then
		Dizzy.DebugShowFrames()
	elseif command == item then
		Dizzy.DebugShowItem()
	elseif command == glob then
		if (rest == "") then print("Syntax: /dz glob <pattern>") else Dizzy.DebugShowGlobal(rest) end
	else
		Dizzy.DebugShowItem()
	end
end
SlashCmdList["DIZZY"] = SlashHandler;

Dizzy.HookOntoTooltipFrame()
Dizzy.CreateDebugFrame()

DEFAULT_CHAT_FRAME:AddMessage("Dizzy is here...")