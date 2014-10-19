Dizzy = Dizzy or {}

Dizzy.show=function()
	if Dizzy.DebugFrame and not Dizzy.DebugFrame:IsVisible() then Dizzy.DebugFrame:Show() end
end

Dizzy.hide=function()
	if Dizzy.DebugFrame and Dizzy.DebugFrame:IsVisible() then Dizzy.DebugFrame:Hide() end
end

Dizzy.GetID = function(ilink)
	if not ilink then return 0 end
	local _,_,iid = strfind(ilink,"|Hitem:(%d+):")
	return tonumber(iid)
end

Dizzy.CacheItem = function(ilink)
	local name, link,
	iQuality, iLevel, reqLevel,
	iclass, isubclass,
	maxStack, equipSlot, texture, vendorPrice = GetItemInfo(ilink)
	local itemid = Dizzy.GetID(link)
	Dizzy.LastSeen = {Name = name, Link = link, Id = itemid,
		Class = iclass, SubClass = isubclass, 
		Quality=iQuality, ItemLevel = iLevel, ReqLevel = reqLevel,
		IsDizzy = Dizzy.IsDizzy(iclass, isubclass, iQuality),
		OfTillersInterest = Dizzy.IsTillerItem(itemid)}
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

Dizzy.UpdateFrameTillers = function(item, frame)
	if not item then return end
	
	local info = Dizzy.TillerItems[item.Id]
	if not info then
		Dizzy.Debug("Couldnt find tiller message for item "..item.Name.." id ".. item.Id)
		return
	end
	
	local members = info.members
	local message = ""
	if item.Id > 79000 then -- its gift
		--[[ commenting out, since adding anything to grift tooltip frame throws an error
		local r,g,b = 0xff, 0xff, 0x00
		local npc1, npc2 = Dizzy.TillerMembers[members[1] ], Dizzy.TillerMembers[members[2] ]		
		if (not npc1) or (not npc2) then Dizzy.Debug("Unknown tiller with ids "..members[1].." or "..members[2]); return end		
		message = npc1.name.." or "..npc2.name.." would love this"
		local _, rep1 = GetFriendshipReputation(npc1.fraction)
		local _, rep2 = GetFriendshipReputation(npc2.fraction)
		Dizzy.Debug("Got reps "..tostring(rep1).." and "..tostring(rep2))
		if (not rep1) or (not rep2) or (rep1>=Dizzy.TillerRepExaltedAt and rep2>=Dizzy.TillerRepExaltedAt) then
			r,g,b = 0.6, 0.6, 0.6
		end				
		frame.AddLine(message, r,g,b, true)
		Dizzy.Debug("Gray")
		if rep1 and rep1 >= Dizzy.TillerRepExaltedAt then
			frame.AddLine("You are already best friends with "..npc1.name, r,g,b, true)
		end
		if rep2 and rep2 >= Dizzy.TillerRepExaltedAt then
			frame.AddLine("You are already best friends with "..npc2.name, r,g,b, true)
		end	
		--]]
	else                    -- it food		
		local npc = Dizzy.TillerMembers[members[1]]
		if not npc then return end
		message = "Favorite dish of "..npc.name
		local _, rep = GetFriendshipReputation(npc.fraction)
		if (rep < Dizzy.TillerRepExaltedAt) then
			frame:AddLine(message, 0, 0x70, 0xdd, true)	
		else
			frame:AddLine(message, 0.6, 0.6, 0.6, true)	
			frame:AddLine("You are already best friends with "..npc.name, 0.6, 0.6, 0.6, true)	
		end		
	end	
	
	--frame:AddLine(tostring(info.message), 0, 0x70, 0xdd, true)	
end

Dizzy.DebugShowItem = function()
	local a1, a2, a3 = GetFriendshipReputation(1273)
	Dizzy.Debug("Rep: "..tostring(a1).." "..tostring(a2).." "..tostring(a3))

	if GameTooltip:IsVisible() then		
		local uname, ulink, some = GameTooltip:GetUnit()
		if uname then
			Dizzy.Debug("Unit "..uname.." "..tostring(ulink).." "..tostring(some))
			return
		end
		
		local name, link = GameTooltip:GetItem()
		local iname, ilink,
			quality, iLevel, reqLevel,
			iclass, isubclass,
			maxStack, equipSlot, texture, vendorPrice = GetItemInfo(link)
		local itemid = Dizzy.GetID(link)
		Dizzy.Debug(ilink.." - "..itemid)
		local dizFlag = Dizzy.IsDizzy(iclass, isubclass,quality) and "DE" or "non-DE"
		local tillersFlag = Dizzy.IsTillerItem(itemid) and "Tillers" or "Not tiller"
		local str = ""..iclass.." ("..tostring(isubclass)..") quality "..quality..", price "..vendorPrice..", "..dizFlag..", "..tillersFlag
		Dizzy.Debug(str)

		local userEP = Dizzy.GetEpOfUserLevel(reqLevel)
		local itemEP, sure = Dizzy.GetEpOfItemLevel(iLevel, quality, iclass)
		str = "Item from expansion "..Dizzy.GetExpansionShortName(itemEP).."("..tostring(itemEP)..")"
		str = str.." wearable in "..Dizzy.GetExpansionShortName(userEP).."("..tostring(userEP)..")"
		Dizzy.Debug(str)
		
		if tillersFlag then
			str = Dizzy.TillerItems[itemid]
			if str then str = str.message end
			Dizzy.Debug("Tiller message: "..tostring(str))
		end
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
	elseif command == "frames" then
		Dizzy.DebugShowFrames()
	elseif command == "item" then
		Dizzy.DebugShowItem()
	elseif command == "glob" then
		if (rest == "") then print("Syntax: /dz glob <pattern>") else Dizzy.DebugShowGlobal(rest) end
	else
		Dizzy.DebugShowItem()
	end
end
SlashCmdList["DIZZY"] = SlashHandler;

Dizzy.HookOntoTooltipFrame()
Dizzy.CreateDebugFrame()

DEFAULT_CHAT_FRAME:AddMessage("Dizzy is here...")