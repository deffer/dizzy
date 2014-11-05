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
    {10940, "Strange Dust"}, {11083, "Soul Dust"}, {11137, "Vision Dust"}, {11176, "Dream Dust"}, {16204, "Illusion Dust"},
    {22445, "Arcane Dust"}, {34054, "Infinite Dust"}, {52555,"Hypnotic Dust"}, {74249,"Spirit Dust"}, {109693,"Draenic Dust"},
    nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
    -- essences [21..50]
    -- "\124cff1eff00\124Hitem:10938:0:0:0:0:0:0:0:0:0:0\124h[Lesser Magic Essence]\124h\124r", -- Lesser Magic Essence
    {10938,"Lesser Magic Essence"}, {10939,"Greater Magic Essence"}, {10998,"Lesser Astral Essence"},
    {11082,"Greater Astral Essence"}, {11134,"Lesser Mystic Essence"}, {11135,"Greater Mystic Essence"},
    {11174,"Lesser Nether Essence"}, {11175,"Greater Nether Essence"}, {16202,"Lesser Eternal Essence"},
    {16203,"Greater Eternal Essence"}, {22447,"Lesser Planar Essence"},{22446,"Greater Planar Essence"},
    {34056,"Lesser Cosmic Essence"},{34055,"Greater Cosmic Essence"}, {52718,"Lesser Celestial Essence"},
    {52719,"Greater Celestial Essence"}, {74250,"Mysterious Essence"},
    nil,nil,nil,  nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
    -- shards [51..80]
    -- "\124cff0070dd\124Hitem:10978:0:0:0:0:0:0:0:0:0:0\124h[Small Glimmering Shard]\124h\124r", -- Small Glimmering Shard
    {10978,"Small Glimmering Shard"},{11084,"Large Glimmering Shard"},{11138,"Small Glowing Shard"},{11139,"Large Glowing Shard"},
    {11177,"Small Radiant Shard"}, {11178,"Large Radiant Shard"}, {14343,"Small Brilliant Shard"}, {14344,"Large Brilliant Shard"},
    {22448,"Small Prismatic Shard"},{22449,"Large Prismatic Shard"},{34053,"Small Dream Shard"}, {34052,"Dream Shard"},
    {52720,"Small Heavenly Shard"},{52721,"Heavenly Shard"},{74252,"Small Ethereal Shard"},{74247,"Ethereal Shard"},
    {115502,"Small Luminous Shard"},{111245,"Luminous Shard"},
    nil,nil, nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,
    --cystals [81..]
    -- "\124cffa335ee\124Hitem:52722:0:0:0:0:0:0:0:0:0:0\124h[Maelstrom Crystal]\124h\124r", -- Maelstrom Crystal
    {52722,"Maelstrom Crystal"}, {34057,"Abyss Crystal"}, {22450,"Void Crystal"}, {20725,"Nexus Crystal"},
    {74248,"Sha Crystal"}, {115504,"Fractured Temporal Crystal"}, {113588,"Temporal Crystal"}
}

Dizzy.GenerateMaterialHref = function(index)
    local mat = Dizzy.Materials[index];
    local colorObject = Dizzy.FindNearestRange(index, Dizzy.MaterialColors);
    if not mat or not colorObject then return "" end;

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

-- three arrays (chances, mats, quantities) are forming a total result of DE of an item

Dizzy.Dis_Chances = {
    -- Armor Green [1] - dusts, [2] - essences, [3] -shards
    -- each pair is max iLevel and percent. sometimes there is 3d value, it is for secondary material
    {
        -- [1] Green Armor dusts: {333,75} => 75% of dust for iLevels [16..333]
        {{15,80}, {333,75}},
        -- [2] Green Armor essences
        {{20, 20}, {25, 15}, {65, 20}, {200, 22}, {333, 25, 2}},
        -- [3] Green Armor shards: {3, 200} => 3% for iLevel [66..200]
        {{0, 15}, {5, 20}, {10, 25}, {5, 65}, {3, 200}}
    },
    -- Weapon Green [1] - dusts, [2] - essences, [3] -shards
    {
        {{20, 20}, {25, 15}, {50, 20}, {200, 22}, {318, 25}}, -- dust
        {{15, 80}, {318, 75}}, -- essences
        {{15, 0}, {20, 5}, {50, 5}, {200, 3}} -- shards. Ex: iLevels [51..22] - 3%
    },
    -- Rare Armor [1] - shards, [2] - crystals
    {
        {{55, 100}, {200, 99.5}, {377, 100}},
        {{55, 0}, {200, 0.5}}
    },
    -- Rare Weapon - almost same as armor, see below
    {},
    -- Epic Armor [1] - shards, [2] - crystals
    {
        {{39, 0}, {55, 100}},
        {{55, 0}, {100, 100}, {164, 22, 67}, {397, 100} } -- [101..164] 22% for main crystal, 67% for secondary crystal
        -- TODO 61-80 	[Nexus Crystal] 	1-2x 	76-80 Weapons: 33% 1x, 67% 2x
    },
    -- Epic Weapon - almost same as armor, see below
    {}
}
Dizzy.Dis_Chances[4] = copy1(Dizzy.Dis_Chances[3])
Dizzy.Dis_Chances[6] = copy1(Dizzy.Dis_Chances[5])


Dizzy.Dis_Mats = {
    -- Armor Green [1] - dusts, [2] - essences, [3] -shards
    {
        -- [1] Green Armor dusts: {333,8} => itemLevel 333 and below breaks into material 8
        {{25, 1}, {35,2}, {45,3}, {55,4}, {65,5}, {120,6}, {200, 7}, {333, 8}, {437,9}, {509, 0}, {700, 10}},
        -- [2] Green Armor essences
        {{15,20}, {20,21}, {25,22}, {30,23}, {35,24}, {40,25}, {45,26}, {50,27}, {55,28}, {65,29},
            {99,30}, {120,31}, {151,32}, {200,33}, {300,34}, {333, 35, 34}, {}, {}},
        -- [3] Green Armor shards
        {{15, 0}, {25}, {30}, {35}, {40}, {45}, {50}, {55}, {65}, {99}, {120},{151},{200}, {0,333}}
    },
    -- Weapon Green [1] - dusts, [2] - essences, [3] -shards (almost same as armors)
    {
        {{1, 25}, {2, 35}, {3, 45}, {4, 55}, {5, 65}, {6, 120}, {7, 200}, {8, 318}},
        {{15}, {20}, {25}, {30}, {35}, {40}, {45}, {50}, {55}, {65}, {99}, {120}, {151}, {200}, {300}, {15, 318}},
        {{0, 15}, {25}, {30}, {35}, {40}, {45}, {50}, {55}, {65}, {99}, {120},{151},{200}, {0,318}}
    },
    -- Rare [1] - shards, [2] - crystals
    {
        {{25}, {30}, {35}, {40}, {45}, {50}, {55}, {65}, {99}, {115}, {164}, {200}, {316}, {377}},
        {{55, 0}, {65}, {99}, {115}, {164}, {200}, {377,0}}
    },{},
    -- Epic
    {
        {{39,0}, {45}, {50}, {55}, {0, 397}},
        {{55,0}, {37, 80, 37}, {38, 164, 38}, {264}, {397}}
    },{}
}
Dizzy.Dis_Mats[4] = copy1(Dizzy.Dis_Mats[3])
Dizzy.Dis_Mats[6] = copy1(Dizzy.Dis_Mats[5])


Dizzy.Dis_Counts = {
    -- Armor Green [1] - dusts, [2] - essences, [3] -shards
    {
        -- [1] Green Armor dusts: {333,8} => itemLevel 333 and below breaks into material 8
        {},
        -- [2] Green Armor essences
        {},
        -- [3] Green Armor shards
        {}
    },
    -- Weapon Green [1] - dusts, [2] - essences, [3] -shards (almost same as armors)
    {
        {},
        {},
        {}
    },
    -- Rare [1] - shards, [2] - crystals
    {
        {},
        {}
    },{},
    -- Epic
    {
        {},
        {}
    },{}
}
Dizzy.Dis_Counts[4] = copy1(Dizzy.Dis_Counts[3])
Dizzy.Dis_Counts[6] = copy1(Dizzy.Dis_Counts[5])

Dizzy.GetItemDisLines = function(iLevel, iQuality, iClass)
    local tidx = Dizzy.GetItemTableIndex(iQuality, iClass)
    if not tidx or tidx == 0 then return {} end

    -- these three arrays should have the same length: 3 (dusts, essences, shards) or 2 (shards and crystals)
    local changesArray = Dizzy.Dis_Chances[tidx];
    local matsArray = Dizzy.Dis_Mats[tidx];
    local countsArray = Dizzy.Dis_Mats[tidx];

    local chances = Dizzy.FindNearestRange(iLevel, changesArray)
    local mats = Dizzy.FindNearestRange(iLevel, matsArray)
    local counts = Dizzy.FindNearestRange(iLevel, countsArray)

    for i,chanceOfMat in ipairs(chances) do
        local chanceValue = chanceOfMat[2]
        local chanceOfSecondaryMat = chanceOfMat[3]

        local currentMat = mats[i][2];
        local secondaryMat = mats[i][3];

        local countValue = counts[i][2];
        local secondaryMatCount = counts[i][3];
    end
end