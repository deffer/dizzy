Dizzy=Dizzy or {}

Dizzy.Expansions = {
	{name = "Vanilla", short="vanilla", from=0, to=60, code=0}, -- index 1 in the array
	{name = "The Burning Crusade", short="BC", from=61, to=70, code=1},
	{name = "Wrath of the Lich King", short="WotLK", from=71, to=80, code=2},
	{name = "Cataclysm", short="cata", from=81, to=85, code=3},
	{name = "Mists of Pandaria", short="MoP", from=86, to=90, code=4 },
	{name = "Down of something", short="DoH",from=91, to=100, code=5 }
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
	{name = "Epic Armor",   ranges={ {f=40,t=83}, {f=95,t=164}, {f=165,t=277}, {f=352,t=397}, {f=420, t=580}, {f=581,t=700}}}
}

Dizzy.TillerItems = {}
-- Gifts
Dizzy.TillerItems[79264] = {message = "Haohan or Tina Mudclaw would love this", members = {57402,58761}}
Dizzy.TillerItems[79265] = {message = "Old Hillpaw or Chee Chee would love this", members = {58707,58709}}
Dizzy.TillerItems[79266] = {message = "Fish Fellreed or Ella would love this", members = {58705,58647}}
Dizzy.TillerItems[79267] = {message = "Jogu or Sho would love this", members = {58710,58708}}
Dizzy.TillerItems[79268] = {message = "Farmer Fung or Gina Mudclaw would love this", members = {57298,58706}}
-- Food
Dizzy.TillerItems[74642] = {message = "Haohan Mudclaw loves this dish", members = {57402}}
Dizzy.TillerItems[74643] = {message = "Jogu loves this dish", members = {58710}}
Dizzy.TillerItems[74644] = {message = "Gina Mudclaw loves this dish", members = {58706}}
Dizzy.TillerItems[74645] = {message = "Sho loves this dish", members = {58708}}
Dizzy.TillerItems[74647] = {message = "Chee Chee loves this dish", members = {58709}}
Dizzy.TillerItems[74649] = {message = "Old Hillpaw loves this dish", members = {58707}}
Dizzy.TillerItems[74651] = {message = "Ella loves this dish", members = {58647}}
Dizzy.TillerItems[74652] = {message = "Tina Mudclaw loves this dish", members = {58761}}
Dizzy.TillerItems[74654] = {message = "Farmer Fung loves this dish", members = {57298}}
Dizzy.TillerItems[74655] = {message = "Fish Fellreed loves this dish", members = {58705}}

Dizzy.TillerMembers = {}
Dizzy.TillerMembers[57298] = {name = "Farmer Fung", fraction=1283}
Dizzy.TillerMembers[58707] = {name = "Old Hillpaw", fraction=1276}
Dizzy.TillerMembers[58705] = {name = "Fish Fellreed", fraction=1282}
Dizzy.TillerMembers[58709] = {name = "Chee Chee", fraction=1277}
Dizzy.TillerMembers[57402] = {name = "Haohan Mudclaw", fraction=1279}
Dizzy.TillerMembers[58761] = {name = "Tina Mudclaw", fraction=1280}
Dizzy.TillerMembers[58706] = {name = "Gina Mudclaw", fraction=1281}
Dizzy.TillerMembers[58708] = {name = "Sho", fraction=1278}
Dizzy.TillerMembers[58647] = {name = "Ella", fraction=1275}
Dizzy.TillerMembers[58710] = {name = "Jogu", fraction=1273}

Dizzy.TillerRepExaltedAt = 42000


Dizzy.GetExpansionShortName = function(index)
	if not index then return "???" end

	local result = Dizzy.Expansions[index]
	if not result then return "???" end

	result = result.short
	return result or "???"
end

Dizzy.IsDizzy = function(iclass, isubclass, iquality)
	-- todo there will be some exceptions, like world even bosses drop, PvP equip, etc
	return (iclass == "Weapon" or iclass == "Armor") and isubclass ~= "Fishing Poles"
		and iquality >1 and iquality <5 -- 2, 3, or 4
end

Dizzy.IsTillerItem = function(id)
	if not id then return false end
	
	-- March lily, Lovely apple, etc...
	if Dizzy.TillerItems[id] then return true else return false end
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


Dizzy.seen={}
Dizzy.DumpGlobals = function(t,i)
	Dizzy.seen[t]=true
	local s={}
	local n=0
	for k in pairs(t) do
		n=n+1 s[n]=k
	end
	table.sort(s)
	for k,v in ipairs(s) do
		print(i,v)
		v=t[v]
		if type(v)=="table" and not Dizzy.seen[v] then
			Dizzy.DumpGlobals(v,i.."\t")
		end
	end
end

-- Dizzy.DumpGlobals(_G,"")


 