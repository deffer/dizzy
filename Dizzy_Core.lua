Dizzy={}

Dizzy.Expansions = {
	{name = "World of Warcraft (no expansions installed)", from=0, to=60, code=0}, -- index 1 in the array
	{name = "World of Warcraft: The Burning Crusade", from=61, to=70, code=1},
	{name = "World of Warcraft: Wrath of the Lich King", from=71, to=80, code=2},
	{name = "World of Warcraft: Cataclysm", from=81, to=85, code=3},
	{name = "World of Warcraft: Mists of Pandaria", from=86, to=90, code=4 },
	{name = "World of Warcraft: Future", from=91, to=100, code=5 }
}

Dizzy.Qualities = {
	{code=0, name="Poor (gray)"},
	{code=1, name="Common (white)"},
	{code=2, name="Uncommon (green)"},
	{code=4, name="Rare / Superior (blue)"},
	{code=5, name="Epic (purple)"},
	{code=6, name="Legendary (orange)"},
	{code=7, name="Artifact (golden yellow)"},
	{code=8, name="Heirloom (light yellow)" }
}

Dizzy.Ranges = {
	--  f = from, t = to. actually, f is not important and here only for readability
	--                                 vanilla       BC            WotLK          Cata           Panda 
	{name = "Green Armor",  ranges={ {f=5, t=65}, {f=79,t=120}, {f=130,t=200}, {f=272,t=333}, {f=364,t=445}}},
	{name = "Green Weapon", ranges={ {f=6, t=65}, {f=80,t=120}, {f=130,t=200}, {f=272,t=318}, {f=364,t=445}}},
	{name = "Blue Armor",   ranges={ {f=1, t=65}, {f=66,t=115}, {f=130,t=200}, {f=292?,t=377?}, {f=364?,t=445?}}},	
	{name = "Epic Armor",   ranges={ {f=40, t=80}, {f=95,t=164}, {f=165?,t=264?}, {f=384?,t=420?}, {f=?, t=600}, {f=?,t=665}}},	
	
}

Dizzy.GetWepOfUserLevel = function(reqLevel)
	for i,v in ipairs(Dizzy.Expansions) do
		if (reqLevel <= v.to) then
			return i
		end
	end
	return nil
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
	local f=CreateFrame("ScrollingMessageFrame", "DizzyDebugBox", UIParent, "InputScrollFrameTemplate")
	f:SetSize(300,300)
	--f.EditBox:SetFontObject("ChatFontNormal")
	f:SetPoint("LEFT")
	return f
end

function Dizzy_DebugFrame()
	local DIZZY_DEBUG_FRAME = CreateDebugFrame()
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
end
 