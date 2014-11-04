Dizzy=Dizzy or {}



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


-- three arrays (chances, items, quantities) are forming a total result of DE of an item

Dizzy.Dis_Chances = {
    -- Armor Green [1] - dusts, [2] - essences, [3] -shards
    -- each pair is max iLevel and percent. sometimes there is 3d value, it is for secondary material
    {
        {{15,80}, {333,75}}, -- dust, Ex: 75% of dust for iLevels [16..333]
        {{20, 20}, {25, 15}, {65, 20}, {200, 22}, {333, 25, 2}}, -- essences
        {{0, 15}, {5, 20}, {10, 25}, {5, 65}, {3, 200}} -- shards. Ex: 3% for iLevel [66..200]
    },
    -- Weapon Green [1] - dusts, [2] - essences, [3] -shards
    {
        {{20, 20}, {25, 15}, {50, 20}, {200, 22}, {318, 25}}, -- dust
        {{15, 80}, {318, 75}}, -- essences
        {{15, 0}, {20, 5}, {50, 5}, {200, 3}} -- shards. Ex: iLevels [51..22] - 3%
    },
    -- Rare [1] - shards, [2] - crystals
    {
        {{55, 100}, {200, 99.5}, {377, 100}},
        {{55, 0}, {200, 0.5}}
    },
    -- Epic  [1] - shards, [2] - crystals
    {
        {{39, 0}, {55, 100}},
        {{55, 0}, {100, 100}, {164, 22, 67}, {397, 100} } -- [101..164] 22% for main crystal, 67% for secondary crystal
        -- TODO 61-80 	[Nexus Crystal] 	1-2x 	76-80 Weapons: 33% 1x, 67% 2x
    }
}


Dizzy.Dis_Items = {
    -- Armor Green [1] - dusts, [2] - essences, [3] -shards
    {
        {{25, 1}, {35,2}, {45,3}, {55,4}, {65,5}, {120,6}, {200, 7}, {333, 8}, {437,9}, {509, 0}, {700, 10}},
        {{15,20}, {20,21}, {25,22}, {30,23}, {35,24}, {40,25}, {45,26}, {50,27}, {55,28}, {65,29},
            {99,30}, {120,31}, {151,32}, {200,33}, {300,34}, {333, 35, 34}, {}, {}},
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
    },
    -- Epic
    {
        {{39,0}, {45}, {50}, {55}, {0, 397}},
        {{55,0}, {37, 80, 37}, {38, 164, 38}, {264}, {397}}
    }
}

