Dizzy=Dizzy or {}

Dizzy.Expansions = {
	{name = "Vanilla", short="vanilla", from=0, to=60, code=0}, -- index 1 in the array
	{name = "The Burning Crusade", short="BC", from=61, to=70, code=1},
	{name = "Wrath of the Lich King", short="WotLK", from=71, to=80, code=2},
	{name = "Cataclysm", short="cata", from=81, to=85, code=3},
	{name = "Mists of Pandaria", short="MoP", from=86, to=90, code=4 },
	{name = "Future", short="Next",from=91, to=100, code=5 }
}

-- not used. Just a reminder
Dizzy.Qualities = {
	{code=0, name="Poor (gray)"},
	{code=1, name="Common (white)"},
	{code=2, name="Uncommon (green)"},
	{code=3, name="Rare / Superior (blue)"},
	{code=4, name="Epic (purple)"},
	{code=5, name="Legendary (orange)"},
	{code=6, name="Artifact (golden yellow)"},
	{code=7, name="Heirloom (light yellow)" }
}

Dizzy.Ranges = {
	--  f = from, t = to. actually, f is not important and is here only as a reminder
	--                                 vanilla       BC            WotLK          Cata           Panda 
	{name = "Green Armor",  ranges={ {f=5, t=65}, {f=79,t=120}, {f=130,t=200}, {f=272,t=333}, {f=364,t=445}}},
	{name = "Green Weapon", ranges={ {f=6, t=65}, {f=80,t=120}, {f=130,t=200}, {f=272,t=318}, {f=364,t=445}}},
	{name = "Blue Armor",   ranges={ {f=1, t=65}, {f=66,t=115}, {f=130,t=200}, {f=288,t=377}, {f=410,t=463}}},
	{name = "Epic Armor",   ranges={ {f=40,t=83}, {f=95,t=164}, {f=165,t=277}, {f=352,t=397}, {f=420, t=535}, {f=536,t=665}}}
}


Dizzy.IsQualityOfInterest = function(iQuality)
	return iQuality >1 and iQuality <5 -- 2, 3, or 4
end


--[[
 intValue is value we are looking for in the ranges array
 ranges is list of pairs (from-to): { {f=5, t=65}, {f=79,t=120}, {f=130,t=200}, {f=272,t=333}, {f=364,t=445} }

 returns index of the range where intValue "belongs" (starts from 1) and boolean indication of certainty.
   If intValue is not found in any of the ranges, then certainty is false and it picks the "approximate" range
   (nearest/lowest "to" that matches).

 Example for the ranges above:
   for intValue 80 returns 2,true  (its in range 79-120)
   for intValue 201 return 4,false (its "probably" in range 272-333 because its below 333)
--]]
Dizzy.FindNearestIndex = function(intValue, ranges)
	local last = 0;
	for i,v in ipairs(ranges) do
		if intValue <= v.t then
			return i, (intValue>=v.f)
		end
		last = i
	end
	return last+1, false
end

-- returns Expansion Pack of given level (WARNING starts from 1. subtract 1 to get wow-type) or nil
Dizzy.GetEpOfUserLevel = function(reqLevel)
	for i,v in ipairs(Dizzy.Expansions) do
		if (reqLevel <= v.to) then
			return i
		end
	end
	return nil
end

-- returns Expansion Pack of given item level (WARNING starts from 1. subtract 1 to get wow-type) and certainty
Dizzy.GetEpOfItemLevel = function(iLevel, iQuality, iClass)
	if not Dizzy.IsQualityOfInterest(iQuality) then
		return nil
	end

	local rangeIndex = 0 -- index in the Dizzy.Ranges array
	if (iQuality == 2) then
		if (iClass == "Weapon") then rangeIndex = 2 elseif (iClass == "Armor") then rangeIndex = 1 end
	else
		rangeIndex = iQuality -- 3-blue, 4-epic
	end

	if rangeIndex == 0 then
		return nil
	end

	local itemWep, sure = Dizzy.FindNearestIndex(iLevel, Dizzy.Ranges[rangeIndex].ranges)
	return itemWep, sure
end


-- http://www.wowwiki.com/Disenchanting_tables

--Dizzy.GetID = function (ilink)
--  local _,_,g = string.find(ilink, "|Hitem:(%d+):")
--  return tonumber(g)
--end

--function GetItemInfo(id)
--	return "Sishir Spellblade of the Sorcerer", "ItemLink", 2, 283, 79, "Weapon", "", 1, 5, 11, 170380
--end



--print("" ..Dizzy.GetID("Coop|Hitem:123:456"))

-- globals.lua
-- show all global variables

Dizzy.seen={}

Dizzy.DumpGlobals = function(t,i)
	seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		print(i,v)
		v=t[v]
		if type(v)=="table" and not seen[v] then
			Dizzy.DumpGlobals(v,i.."\t")
		end
	end
end

-- Dizzy_dump(_G,"")

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
	local f=CreateFrame("Frame", "DizzyDebugBox", UIParent, "ChatFrameTemplate")
	f:SetSize(300,300)
	--f:SetMinSize(20, 20)
	--f.EditBox:SetFontObject("ChatFontNormal")
	-- f:SetPoint("LEFT")
	f:SetPoint("CENTER", UIParent, "CENTER")
	f:SetBackdrop({bgFile = [[Interface\Buttons\WHITE8X8]]})
	f:CreateTitleRegion()
	return f
end

function Dizzy_DebugFrame()
	DIZZY_DEBUG_FRAME = CreateDebugFrame()	
	local kids = {DIZZY_DEBUG_FRAME:GetChildren()};	
	for _,v in ipairs(kids) do
		DEFAULT_CHAT_FRAME:AddMessage("Child frame ");
		if (v) then
			local cit_name = v:GetName();
			if ( cit_name ) then    
				DEFAULT_CHAT_FRAME:AddMessage("Child frame " .. cit_name .. " ");
			end
		end
	end 
end
 