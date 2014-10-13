Dizzy = Dizzy or {}

Dizzy.CacheItem = function(ilink)
	local name, link,
	iQuality, iLevel, reqLevel,
	iclass, isubclass,
	maxStack, equipSlot, texture, vendorPrice = GetItemInfo(ilink)
	Dizzy.LastSeen = {Name = name, Link = link, 
		Class = iclass, SubClass = isubclass, 
		Quality=iQuality, ItemLevel = iLevel, ReqLevel = reqLevel,
		OfInterest = Dizzy.IsItemOfInterest(iclass, isubclass) and Dizzy.IsQualityOfInterest(iQuality)}
end

Dizzy.IsItemOfInterest = function(iclass, isubclass)
	return (iclass == "Weapon" or iclass == "Armor")
	  and not (isubclass == "Fishing Poles")
end

Dizzy.UpdateFrame = function(item, frame)
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
	local itemEpStr = Dizzy.Expansions[itemEP].short.." "..itemEP.." > "..userEP.." ("..item.ItemLevel..","..item.Quality..","..item.Class..")"
	if (not sure) then
		itemEpStr = itemEpStr.."(?)"
	end
	--local str = ""..item.Class.." ("..tostring(item.SubClass)..")"
	frame:AddLine(itemEpStr, r, g, b, true)
	frame:Show()
end

Dizzy.GetID = function(ilink)
	local _,_,iid = strfind(ilink,"|Hitem:(%d+):")
	return tonumber(iid)
end

local function Dizzy_ShowEverything()
	local frame = EnumerateFrames()
	while frame do
		if frame:IsVisible() and MouseIsOver(frame) then
			DEFAULT_CHAT_FRAME:AddMessage(frame:GetName() .. " - " .. frame:GetID())			
		end
		frame = EnumerateFrames(frame)
	end
	

	if GameTooltip:IsVisible() then		
		local name, link = GameTooltip:GetItem()
		local iname, ilink,
			quality, iLevel, reqLevel,
			iclass, isubclass,
			maxStack, equipSlot, texture, vendorPrice = GetItemInfo(link)
	
		local str = ""..iclass.." ("..tostring(isubclass)..") "..quality.." price "..vendorPrice		
		local userEP = Dizzy.GetEpOfUserLevel(reqLevel)
		local itemEP, sure = Dizzy.GetEpOfItemLevel(iLevel, quality, iclass)
		str = str.." "..userEP.." > "..itemEP
		
		str = str.." "..tostring(Dizzy.IsItemOfInterest(iclass, isubclass)).." "..tostring(Dizzy.IsQualityOfInterest(quality))

		DEFAULT_CHAT_FRAME:AddMessage(str)
		
		local tl = _G[GameTooltip:GetName().."TextLeft"..2]; 
		if (t1) then
			DEFAULT_CHAT_FRAME:AddMessage("Found t2")
		end
		
		tl = _G[GameTooltip:GetName().."TextLeft"..1]; 
		if (t1) then
			DEFAULT_CHAT_FRAME:AddMessage("Found t1")
		end
	end		
end

function Dizzy_Load()
	if(GameTooltip:GetScript("OnTooltipSetItem")) then
		GameTooltip:HookScript("OnTooltipSetItem",Dizzy_AddInfo);
	else
		GameTooltip:SetScript("OnTooltipSetItem",Dizzy_AddInfo);
	end
	if(ItemRefTooltip:GetScript("OnTooltipSetItem")) then
		ItemRefTooltip:HookScript("OnTooltipSetItem",Dizzy_AddInfo);
	else
		ItemRefTooltip:SetScript("OnTooltipSetItem",Dizzy_AddInfo);
	end
	if(GameTooltip:GetScript("OnHide")) then
		GameTooltip:HookScript("OnHide",Dizzy_OnHide);
	else
		GameTooltip:SetScript("OnHide",Dizzy_OnHide);
	end	
end

function Dizzy_OnHide(this)
end

function Dizzy_AddInfo(this)
	local iname,ilink = this:GetItem();
	local windowsName = this:GetName()

	if ((not Dizzy.LastSeen) or not (Dizzy.LastSeen.Link == ilink)) then
		Dizzy.CacheItem(ilink)
	end

	if Dizzy.LastSeen then
		local item = Dizzy.LastSeen
		if item.OfInterest then
			--DEFAULT_CHAT_FRAME:AddMessage("u...")
			Dizzy.UpdateFrame(item, this)
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("Nothing in cache for : "..ilink)
	end
end
 
SLASH_DIZZY1 = "/dizzy"
SLASH_DIZZY2 = "/dz"
local function SlashHandler(msg, editbox)
	Dizzy_ShowEverything()
end
SlashCmdList["DIZZY"] = SlashHandler;

Dizzy_Load()

DEFAULT_CHAT_FRAME:AddMessage("Dizzy is here...")