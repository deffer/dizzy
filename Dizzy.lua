Dizzy = Dizzy or {}

Dizzy.CacheItem = function(ilink)
	local name, link,
	quality, iLevel, reqLevel,
	iclass, isubclass,
	maxStack, equipSlot, texture, vendorPrice = GetItemInfo(ilink)
	Dizzy.LastSeen = {Name = name, Link = link, 
		Class = iclass, SubClass = isubclass, 
		ItemLevel = iLevel, ReqLevel = reqLevel,
		IsItemOfInterest = Dizzy.IsItemOfInterest(iclass, isubclass)}
end

Dizzy.IsItemHot = function()
	-- TODO implement
	if (reqLevel < 81 and iLevel > 272) then
		return true
	else
		return false
	end
end

Dizzy.IsItemOfInterest = function(iclass, isubclass)
	return (iclass == "Weapon" or iclass == "Armor")
	  and not (isubclass == "Fishing Poles")
end

Dizzy.GetID = function(ilink)
	local _,_,iid = strfind(ilink,"|Hitem:(%d+):")
	return tonumber(iid)
end

local function ShowEverything()
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

	if (Dizzy.LastSeen and Dizzy.LastSeen.Link == ilink) then
		--DEFAULT_CHAT_FRAME:AddMessage("Hook: "..iname)
	else		
		Dizzy.CacheItem(ilink)
	end


	if Dizzy.LastSeen then
		local item = Dizzy.LastSeen
		if item.IsItemOfInterest then
			local str = ""..item.Class.." ("..tostring(item.SubClass)..")"
			this:AddLine(str, "40", "c0", "40", true)
			this:Show()
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("Nothing in cache for : "..ilink)
	end
end
 
SLASH_DIZZY1 = "/dizzy"
SLASH_DIZZY2 = "/dz"
local function SlashHandler(msg, editbox)
	ShowEverything()
end
SlashCmdList["DIZZY"] = SlashHandler;

Dizzy_Load()

DEFAULT_CHAT_FRAME:AddMessage("Dizzy is here...")