Dizzy=Dizzy or {}

-- simple copy. suffice for our tables
local function copy1(obj)
    if type(obj) ~= 'table' then return obj end
    local res = {}
    for k, v in pairs(obj) do res[copy1(k)] = copy1(v) end
    return res
end

Dizzy.MaterialColors = {
    {20, "ffffffff"}, {50, "ff1eff00"}, {80, "ff0070dd"}, {120, "ffa335ee"}
}

Dizzy.Materials = {
    -- dusts [1..20]
    --"\124cffffffff\124Hitem:10940:0:0:0:0:0:0:0:0:0:0\124h[Strange Dust]\124h\124r", -- Strange Dust
    {10940, "Strange Dust"}, {11083, "Soul Dust"}, {11137, "Vision Dust"}, {11176, "Dream Dust"}, {16204, "Illusion Dust"}, -- 1-5
    {22445, "Arcane Dust"}, {34054, "Infinite Dust"}, {52555,"Hypnotic Dust"}, {74249,"Spirit Dust"}, {109693,"Draenic Dust"}, -- 6-10
    nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
    -- essences [21..50]
    -- "\124cff1eff00\124Hitem:10938:0:0:0:0:0:0:0:0:0:0\124h[Lesser Magic Essence]\124h\124r", -- Lesser Magic Essence
    {10938,"Lesser Magic Essence"}, {10939,"Greater Magic Essence"}, {10998,"Lesser Astral Essence"},
    {11082,"Greater Astral Essence"}, {11134,"Lesser Mystic Essence"}, {11135,"Greater Mystic Essence"},--24,25,26
    {11174,"Lesser Nether Essence"}, {11175,"Greater Nether Essence"}, {16202,"Lesser Eternal Essence"},--27,28,29
    {16203,"Greater Eternal Essence"}, {22447,"Lesser Planar Essence"},{22446,"Greater Planar Essence"},--30,31,32
    {34056,"Lesser Cosmic Essence"},{34055,"Greater Cosmic Essence"}, {52718,"Lesser Celestial Essence"},--33,34,35
    {52719,"Greater Celestial Essence"}, {74250,"Mysterious Essence"},--36,37
    nil,nil,nil,  nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
    -- shards [51..80]
    -- "\124cff0070dd\124Hitem:10978:0:0:0:0:0:0:0:0:0:0\124h[Small Glimmering Shard]\124h\124r", -- Small Glimmering Shard
    {10978,"Small Glimmering Shard"},{11084,"Large Glimmering Shard"},{11138,"Small Glowing Shard"},{11139,"Large Glowing Shard"},--51,52,53,54
    {11177,"Small Radiant Shard"}, {11178,"Large Radiant Shard"}, {14343,"Small Brilliant Shard"}, {14344,"Large Brilliant Shard"},--55,56,57,58
    {22448,"Small Prismatic Shard"},{22449,"Large Prismatic Shard"},{34053,"Small Dream Shard"}, {34052,"Dream Shard"},--59,60,61,62
    {52720,"Small Heavenly Shard"},{52721,"Heavenly Shard"},{74252,"Small Ethereal Shard"},{74247,"Ethereal Shard"},--63,64,65,66
    {115502,"Small Luminous Shard"},{111245,"Luminous Shard"},--67,68
    nil,nil, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
    --cystals [81..]
    -- "\124cffa335ee\124Hitem:52722:0:0:0:0:0:0:0:0:0:0\124h[Maelstrom Crystal]\124h\124r", -- Maelstrom Crystal
    {20725,"Nexus Crystal"}, {22450,"Void Crystal"}, {34057,"Abyss Crystal"}, {52722,"Maelstrom Crystal"}, --81-84
    {74248,"Sha Crystal"}, {115504,"Fractured Temporal Crystal"}, {113588,"Temporal Crystal"} -- 85-87
}

Dizzy.GenerateMaterialHref = function(index)
    if index == 0 then return "[Error material] 0" end

    local mat = Dizzy.Materials[index];
    local colorObject = Dizzy.FindNearestRange(index, Dizzy.MaterialColors);
    if not mat or not colorObject then return "Unknown material "..tostring(index) end;

    local id = tostring(mat[1])
    local name = tostring(mat[2])
    local colorStr = tostring(colorObject[2])
    local result = "\124c"..colorStr.."\124Hitem:"..id.."\124h["..name.."]\124h\124r"
    return result
end

Dizzy.FindNearestRange = function(intValue, ranges)
    local last;
    for i,v in ipairs(ranges) do
        if intValue <= v[1] then
            return v
        end
        last = v
    end
    return last
end

-- three arrays (chances, mats, quantities) are forming a total result of DE of an item

Dizzy.Dis_Chances = {
    -- Armor Green [1] - dusts, [2] - essences, [3] -shards
    -- each pair is max iLevel and percent. sometimes there is 3d value, it is for secondary material
    {
        -- [1] Green Armor dusts: {333,75} => 75% of dust for iLevels [16..333]
        {{15,80}, {333,75},    {437, 85}, {700, "75(?)"}},
        -- [2] Green Armor essences
        {{20, 20}, {25, 15}, {65, 20}, {200, 22}, {333, 25, 2}, {437, 15},   {700,0}},
        -- [3] Green Armor shards: {3, 200} => 3% for iLevel [66..200]
        {{15,0}, {20,5}, {25,10}, {65,5}, {200,3},    {700,0}}
    },
    -- Weapon Green [1] - dusts, [2] - essences, [3] -shards
    {
        {{20, 20}, {25, 15}, {50, 20}, {200, 22}, {318, 25},   {437, 85}, {700,"25(?)"}}, -- dust
        {{15, 80}, {318, 75},   {437, 15},   {700,0}}, -- essences  (TODO 437 range: precents of dust and essences may be opposite)
        {{15, 0}, {20, 5}, {50, 5}, {200, 3},    {700,0}} -- shards. Ex: iLevels [51..22] - 3%
    },
    -- Rare Armor [1] - shards, [2] - crystals
    {
        {{55, 100}, {164, 99.5}, {316, 96,4}, {377, 95,5}, {476, 89,11},
            {630, "~30-80", "~20-70"},     {700,0}},
        {{55, 0}, {164, 0.5}, {377,0},   {700,0}}
    },
    -- Rare Weapon - almost same as armor
    {
        {{55, 100}, {200, 99.5}, {316, 96,4}, {377, 95,5}, {476, 89,11},
            {630, "~30-80", "~20-70"},    {700,0}},
        {{55, 0}, {200, 0.5}, {377, 0},    {700,0}}
    },
    -- Epic Armor [1] - shards, [2] - crystals
    {
        {{39, 0}, {55, 100}, {397,0},  {710,0}},
        {{55, 0}, {100, 100}, {164, 33, 67}, {397, 100}, {419,0},
            {535,100},{553, 100},    {710,0} } -- [101..164] 33% for main crystal, 67% for secondary crystal
    },
    -- Epic Weapon - almost same as armor
    {
        {{39, 0}, {55, 100}, {397,0},  {710,0}},
        {{55, 0}, {60, 100}, {80, 33, 67}, {100, 100}, {164, 33, 67}, {397, 100}, {419,0},
            {535,100}, {553, 100},    {710,0} }
    }
}



Dizzy.Dis_Mats = {
    -- Armor Green [1] - dusts, [2] - essences, [3] -shards
    {
        -- [1] Green Armor dusts: {333,8} => itemLevel 333 and below breaks into material 8
        {{25, 1}, {35,2}, {45,3}, {55,4}, {65,5}, {120,6}, {200, 7}, {333, 8},    {437,9}, {509, 0}, {700, 10}},
        -- [2] Green Armor essences
        {{15,21}, {20,22}, {25,23}, {30,24}, {35,25}, {40,26}, {45,27}, {50,28}, {55,29}, {65,30},
            {99,31}, {120,32}, {151,33}, {200,34}, {300,35}, {333, 36, 35},   {437, 37}, {509,0}, {700, 0}},
        -- [3] Green Armor shards
        {{15, 0}, {25,51}, {30,52}, {35, 53}, {40, 54}, {45,55}, {50,56}, {55,57}, {65,58}, {99,59},
            {120,60},{151,61},{200,62},   {333, 0}, {700, 0}}
    },
    -- Weapon Green [1] - dusts, [2] - essences, [3] -shards (almost same as armors)
    {
        {{25, 1}, {35,2}, {45,3}, {55,4}, {65,5}, {120,6}, {200, 7}, {318, 8},    {437,9}, {509, 0}, {700, 10}},
        {{15,21}, {20,22}, {25,23}, {30,24}, {35,25}, {40,26}, {45,27}, {50,28}, {55,29}, {65,30},
            {99,31}, {120,32}, {151,33}, {200,34}, {300,35}, {318, 36},     {437, 37}, {509,0}, {700, 0}},
        {{15, 0}, {25,51}, {30,52}, {35, 53}, {40, 54}, {45,55}, {50,56}, {55,57}, {65,58}, {99,59},
            {120,60},{151,61},{200,62},     {333, 0}, {700, 0}}
    },
    -- Rare Armor [1] - shards, [2] - crystals
    {
        {{25, 51}, {30,52}, {35,53}, {40,54}, {45,55}, {50, 56}, {55,57}, {65,58}, {99,59}, {115,60}, {164,61},
            {200,62}, {316,63, 63}, {377,64,64}, {424, 65,65}, {476, 66,66},
            {630, 67, 68}, {700,0}},
        {{55, 0}, {99, 81}, {115, 82}, {200, 83}, {377,0},    {700,0}}
    },
    -- Rare Weapon [1] - shards, [2] - crystals
    {
        {{25, 51}, {30,52}, {35,53}, {40,54}, {45,55}, {50, 56}, {55,57}, {65,58}, {99,59}, {115,60}, {164,61},
            {200,62}, {316,63,63}, {377,64,64}, {424, 65,65},{476, 66,66},
            {630, 67, 68},    {700,0}},
        {{55, 0}, {99, 81}, {115, 82}, {164, 83}, {200, 83}, {377,0},    {700,0}}
    },
    -- Epic Armor
    {
        {{39,0}, {45, 55}, {50, 56}, {55, 57}, {397, 0},  {700,0}},
        {{55,0}, {80, 81}, {164, 82}, {264,83}, {397,84},{419,0}, {535,85}, {553, 85},  {700,0}}
    },
    {} -- Epic Weapon - a copy of armor
}
Dizzy.Dis_Mats[6] = copy1(Dizzy.Dis_Mats[5])


Dizzy.Dis_Counts = {
    -- Armor Green [1] - dusts, [2] - essences, [3] -shards
    {
        -- [1] Green Armor dusts: {333,8} => itemLevel 333 and below breaks into material 8
        {{15, "1-2"}, {20, "2-3"}, {25, "4-6"},{30, "1-2"}, {35,"2-5"}, {40, "1-2"}, {45, "2-5"}, {50, "1-2"},
            {55, "2-5"}, {60, "1-2"}, {65, "2-5"}, {79, "1-3"}, {99, "2-3"}, {120, "2-5"}, {150, "1-3"}, {200, "2-7"},
            {300, "1-9"}, {333, "1-10"},   {437, "1-9"},{700,"?"}},
        -- [2] Green Armor essences
        {   {60, "1-2"}, {65, "2-3"}, {79, "1-3"}, {99, "2-3"}, {200, "1-2"}, {300, "1-8"}, {333, "1-4", "1-3"},   {700,1}},
        -- [3] Green Armor shards
        {{15,0}, {200,1}, {333, 0},   {700, 1}}
    },
    -- Weapon Green [1] - dusts, [2] - essences, [3] -shards (almost same as armors)
    {
        {{15, "1-2"}, {20, "2-3"}, {25, "4-6"},{30, "1-2"}, {35,"2-5"}, {40, "1-2"}, {45, "2-5"}, {50, "1-2"},
            {55, "2-5"}, {60, "1-2"}, {65, "2-5"}, {99, "2-3"}, {120, "2-5"}, {151, "1-3"}, {200, "4-7"},
            {300, "1-7"}, {317, "1-10"}, {318, "?"},   {437, "1-9"},{700,"?"}},
        {{60, "1-2"},  {99, "2-3"}, {99, "2-3"}, {200, "1-2"}, {300, "1-8"}, {317, "1-5"},{318, "?"},   {700,1}},
        {{15,0}, {200,1}, {700,0}}
    },
    -- Rare Armor [1] - shards, [2] - crystals
    {
        {{200,1}, {316, 1,2}, {377, 1, 2}, {424, 1,2}, {476,1,2}, {630, "1-8?", "1-2?"},  {700,1}},
        {{55,0}, {200,1}, {377, 0},{700,0}}
    }, -- weapon is a copy of armor
    {},
    -- Epic Armor
    {
        {{39, 0}, {55, "2-4"},  {397,0},   {700,1}},
        {{55, 0}, {60, "1"}, {100, "1-2"}, {164, 1,2}, {200,1}, {397, "1-2"},
            {419,0}, {535,"1-3"}, {553, "1-2"},   {700,1}}
    },
    -- Epic Weapon
    {
        {{39, 0}, {55, "2-4"},  {397,0},   {700,1}},
        {{55, 0}, {60, "1"}, {80, "1", "2"}, {100, "1-2"}, {164, 1,2}, {200,1}, {397, "1-2"},
            {419,0}, {535,"1-3"}, {553, "1-2"},   {700,1}}
    }
}
Dizzy.Dis_Counts[4] = copy1(Dizzy.Dis_Counts[3])


Dizzy.GetItemDisLines = function(iLevel, iQuality, iClass, itemName, forDebug)
    if iLevel == 450 and string.find(itemName, "Contender's") then
        return {Dizzy.GenerateDisMatLine({450, 85, 15},{450, 65, 65}, {450,1,2}, forDebug)}
    end

    local result = {}
    local iLines=1
    local tidx = Dizzy.GetItemTableIndex(iQuality, iClass)
    if not tidx or tidx == 0 or tidx>6 then return {"Error "..tostring(tidx)} end

    -- these three arrays should have the same length: 3 (dusts, essences, shards) or 2 (shards and crystals)
    local chancesArray = Dizzy.Dis_Chances[tidx];
    local matsArray = Dizzy.Dis_Mats[tidx];
    local countsArray = Dizzy.Dis_Counts[tidx];
    if not chancesArray or not matsArray or not countsArray then return {"Tables not found"} end

    for i,chanceOfMatArray in ipairs(chancesArray) do
        -- chanceOfMatArray is dust, or essence, or shard, or crystal. {{},{},{}...}
        local chanceInfo = Dizzy.FindNearestRange(iLevel, chanceOfMatArray)
        local matInfo = Dizzy.FindNearestRange(iLevel, matsArray[i])
        local countInfo = Dizzy.FindNearestRange(iLevel, countsArray[i])
        if not chanceInfo or not matInfo or not countInfo then return {"Range not found"} end

        local lines = Dizzy.GenerateDisMatLine(chanceInfo, matInfo, countInfo, forDebug)
        if not lines then return {"No info available"} end

        if lines[1] then
            result[iLines] = lines[1]
            iLines = iLines+1
        end

        if lines[2] then
            result[iLines] = lines[2]
            iLines = iLines+1
        end
    end
    return result
end

-- each info is pair or triple like {300, 15} or {300,15,14},
--  300 is top level, 15 is actual value (percent or material or amount)
--  14 is secondary value - sometimes items disenchants on two difference essences (or same mat but different
--    chance/amount) ex: (2-3) lesser essence 75%, (1-2) greater essence 25%
-- RETURNS normally an array (1 or 2 values) of string
--   empty array means no DE for given material (0 chance or 0 amount)
--   nil means error
--   in debug mode return error/debug strings (never nil)
Dizzy.GenerateDisMatLine = function(chanceInfo, matInfo, countInfo, forDebug)
    local result = {}
    local chance1 = chanceInfo[2]
    local mat1 = matInfo[2];
    local amount1 = countInfo[2];

    local chance2 = chanceInfo[3] -- secondary material's chance
    local mat2 = matInfo[3];      -- secondary material's id
    local amount2 = countInfo[3]; -- secondary material's amount

    if chance1 and mat1 and amount1 then
        if Dizzy.AnyZero({ chance1, mat1, amount1 }, 3) then -- 0 indicates no DE for this dust/essence/shard/crystal
            return forDebug and {"Skip "..Dizzy.GenerateMaterialHref(mat1).." "..tostring(chance1).."%  "..tostring(amount1)} or {}
        else
            local str = ""..Dizzy.GenerateMaterialHref(mat1).." "..tostring(chance1).."%"
            if amount1 ~= 1 and amount1 ~= "1" then
                str = str .. " ("..tostring(amount1)..")"
            end
            result[1] = str

            -- secondary material/chance
            if Dizzy.AnyNonZero({ chance2, mat2, amount2 }, 3) then
                chance2, mat2, amount2 = Dizzy.MergeArrays({ chance1, mat1, amount1 }, { chance2, mat2, amount2 })
                local str = ""..Dizzy.GenerateMaterialHref(mat2).." "..tostring(chance2).."%"
                if amount2 ~= 1 and amount2 ~= "1" then
                    str = str .. " ("..tostring(amount2)..")"
                end
                result[2] = str
            end
        end
    else
        return forDebug and {"Fail: mat="..tostring(mat1).." chance="..tostring(chance1).." amount="..tostring()} or nil
    end

    return result
end

Dizzy.MergeArrays = function(arraySource, arrayTarget)
    for k,v in ipairs(arraySource) do
        if not arrayTarget[k] then arrayTarget[k] = v end
    end
    return unpack(arrayTarget)
end

