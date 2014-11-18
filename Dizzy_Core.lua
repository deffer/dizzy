Dizzy=Dizzy or {}

Dizzy.Expansions = {
	{name = "Vanilla", short="Vanilla", from=0, to=60, code=0}, -- index 1 in the array
	{name = "The Burning Crusade", short="BC", from=61, to=70, code=1},
	{name = "Wrath of the Lich King", short="WotLK", from=71, to=80, code=2},
	{name = "Cataclysm", short="Cata", from=81, to=85, code=3},
	{name = "Mists of Pandaria", short="MoP", from=86, to=90, code=4 },
	{name = "Warlords of Draenor", short="WoD",from=91, to=100, code=5 },
    {name = "Unknown", short="Unknown",from=101, to=9000, code=6 },
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
	--   {from, to}                 vanilla     BC       WotLK      Cata       Panda       wod
	{name = "Green Armor",  ranges={ {5,65}, {79,120}, {130,200}, {272,333}, {364,445}, {509,700}}},
	{name = "Green Weapon", ranges={ {6,65}, {80,120}, {130,200}, {272,318}, {364,445}, {509,700}}},
	{name = "Blue Armor",   ranges={ {1,65}, {66,115}, {130,200}, {288,377}, {410,476}, {509,700}}},
	{name = "Blue Weapon",  ranges={ {1,65}, {66,115}, {130,200}, {288,377}, {410,476}, {509,700}}}, --{410-463,476}
	{name = "Epic Armor",   ranges={ {40,83}, {95,164}, {165,277}, {352,397}, {420,580}, {509,700}}},
	{name = "Epic weapon",  ranges={ {40,83}, {95,164}, {165,277}, {352,397}, {420,580}, {509,700}}}
}

Dizzy.GetExpansionShortName = function(index)
	if not index then return "???" end

	local result = Dizzy.Expansions[index]
	if not result then return "???" end

	result = result.short
	return result or "???"
end

-- returns index in the arrays like Ranges,Dis_Chances,etc..
-- iQuality -- 2-green, 3-blue, 4-epic
Dizzy.GetItemTableIndex = function(iQuality, iClass)
    if iQuality<2 then return 0 end

    -- (iQuality - 2)*2 => green=0, blue=2, epic=4
    -- (+1) to shift in the array because its lua => 1,3,5
    -- (+1) if weapon => 2,4,6
    local rangeIndex = (iQuality - 2)*2 + 1
    if iClass == "Weapon" then rangeIndex = rangeIndex+1 end
    return rangeIndex
end

Dizzy.IsDizzy = function(iclass, isubclass, iquality)
	-- todo there will be some exceptions, like world even bosses drop, PvP equip, Mist-Piercing Goggles, Terracota Fragment, etc
	return (iclass == "Weapon" or iclass == "Armor") and isubclass ~= "Fishing Poles"
		and iquality >1 and iquality <5 -- 2, 3, or 4
end

Dizzy.IsDizzy1 = function(arguments)
-- todo there will be some exceptions, like world even bosses drop, PvP equip, Mist-Piercing Goggles, etc
    local iname, ilink,
    quality, iLevel, reqLevel,
    iclass, isubclass,
    maxStack, equipSlot, texture, vendorPrice = unpack(arguments)

    return (iclass == "Weapon" or iclass == "Armor") and isubclass ~= "Fishing Poles"
            and maxStack==1 and vendorPrice > 10 -- todo is it string??
            and quality >1 and quality <5 -- 2, 3, or 4
end

--[[
 intValue is value we are looking for in the ranges array
 ranges is list of pairs (from-to): { {5, 65}, {79,120}, {130,200}, {272,333}, {364,445} }

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
		if intValue <= v[2] then
			return i, (intValue>=v[1])
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
    -- index in the Dizzy.Ranges array
    local rangeIndex = Dizzy.GetItemTableIndex(iQuality, iClass)

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

function range(a, b, step)
    if not b then
        b = a
        a = 1
    end
    step = step or 1
    local f =
    step > 0 and
            function(_, lastvalue)
                local nextvalue = lastvalue + step
                if nextvalue <= b then return nextvalue end
            end or
            step < 0 and
            function(_, lastvalue)
                local nextvalue = lastvalue + step
                if nextvalue >= b then return nextvalue end
            end or
            function(_, lastvalue) return lastvalue end
    return f, nil, a - step
end

Dizzy.AnyZero = function(input, count)
    for i in range(count) do
        local v = input[i]
        if not v or v == 0 then return true end
    end
    return false
end


Dizzy.AnyNonZero = function(input, count)
    for i in range(count) do
        local v = input[i]
        if v and v ~= 0 then return true end
    end
    return false
end

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


 