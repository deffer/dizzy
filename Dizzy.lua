function printHello()   
	DEFAULT_CHAT_FRAME:AddMessage("Dizzy is here...")
end

function Dizzy_GetID(ilink)
	local _,_,iid = strfind(ilink,"|Hitem:(%d+):")
	return tonumber(iid)
end

DIZZY_DEBUG_FRAME = nil;
local function CreateDebugFrameMultiline()
	local f=CreateFrame("ScrollFrame", "DizzyDebugBox", UIParent, "InputScrollFrameTemplate")
	f:SetSize(300,300)
	-- f:SetPoint("CENTER")
	f:SetPoint("LEFT")
	f.EditBox:SetFontObject("ChatFontNormal")
	f.EditBox:SetMaxLetters(1024)
	f.CharCount:Hide()
	return f
	-- or use http://wowprogramming.com/docs/widgets/ScrollingMessageFrame
end

local function CreateDebugFrame()
	local f=CreateFrame("ScrollingMessageFrame", "DizzyDebugBox", UIParent, "InputScrollFrameTemplate")
	f:SetSize(300,300)
	--f.EditBox:SetFontObject("ChatFontNormal")
	f:SetPoint("LEFT")
	return f
end

local function ShowTheFrames()
	local frame = EnumerateFrames()
	while frame do
		if frame:IsVisible() and MouseIsOver(frame) then
			DEFAULT_CHAT_FRAME:AddMessage(frame:GetName() .. " - " .. frame:GetID())			
		end
		frame = EnumerateFrames(frame)
	end
	

	if GameTooltip:IsVisible() then		
		local name, link = GameTooltip:GetItem()			
		DEFAULT_CHAT_FRAME:AddMessage("GameTooltip " .. name .. " - " .. link)
		GameTooltip:AddLine("Hello there")
		GameTooltip:Show()
	end	
	
	DEFAULT_CHAT_FRAME:AddMessage("showing")
	DIZZY_DEBUG_FRAME:AddMessage("Hello swetie")
	DIZZY_DEBUG_FRAME:Show()
	DIZZY_DEBUG_FRAME:AddMessage("Hello swetie2")
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
	local _,link = this:GetItem();
	local itemName = this:GetName()

	DIZZY_DEBUG_FRAME:AddMessage("Dizzy: "..itemName)

	if link then
		local iname,_,irare,ilvl,imin,itype,isubtype,istack,iequloc,itex,isell = GetItemInfo(link);
		local iid = Dizzy_GetID(link)
		this:AddLine("Dizzy: "..iname);
		this:Show();
	end
end
 

SLASH_DIZZY1 = "/dizzy"
SLASH_DIZZY2 = "/dz"
local function SlashHandler(msg, editbox)
	--print("Usage")
	ShowTheFrames()
end
SlashCmdList["DIZZY"] = SlashHandler;

DIZZY_DEBUG_FRAME = CreateDebugFrame()
local kids = {DIZZY_DEBUG_FRAME:GetChildren()};	
for _,v in pairs(kids) do
	DEFAULT_CHAT_FRAME:AddMessage("Child frame ");
	if (v) then
		local cit_name = v:GetName();
		if ( cit_name ) then    
			DEFAULT_CHAT_FRAME:AddMessage("Child frame " .. cit_name .. " ");
		end
	end
end 

printHello()