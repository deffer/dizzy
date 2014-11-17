Dizzy=Dizzy or {}

Dizzy.TillerItems = {
    -- Gifts
    [79264] = {message = "Haohan or Tina Mudclaw would love this", members = {57402,58761}},
    [79265] = {message = "Old Hillpaw or Chee Chee would love this", members = {58707,58709}},
    [79266] = {message = "Fish Fellreed or Ella would love this", members = {58705,58647}},
    [79267] = {message = "Jogu or Sho would love this", members = {58710,58708}},
    [79268] = {message = "Farmer Fung or Gina Mudclaw would love this", members = {57298,58706}},
    -- Food
    [74642] = {message = "Haohan Mudclaw loves this dish", members = {57402}},
    [74643] = {message = "Jogu loves this dish", members = {58710}},
    [74644] = {message = "Gina Mudclaw loves this dish", members = {58706}},
    [74645] = {message = "Sho loves this dish", members = {58708}},
    [74647] = {message = "Chee Chee loves this dish", members = {58709}},
    [74649] = {message = "Old Hillpaw loves this dish", members = {58707}},
    [74651] = {message = "Ella loves this dish", members = {58647}},
    [74652] = {message = "Tina Mudclaw loves this dish", members = {58761}},
    [74654] = {message = "Farmer Fung loves this dish", members = {57298}},
    [74655] = {message = "Fish Fellreed loves this dish", members = {58705}}
}

Dizzy.TillerMembers = {
    [57298] = {name = "Farmer Fung", fraction=1283},
    [58707] = {name = "Old Hillpaw", fraction=1276},
    [58705] = {name = "Fish Fellreed", fraction=1282},
    [58709] = {name = "Chee Chee", fraction=1277},
    [57402] = {name = "Haohan Mudclaw", fraction=1279},
    [58761] = {name = "Tina Mudclaw", fraction=1280},
    [58706] = {name = "Gina Mudclaw", fraction=1281},
    [58708] = {name = "Sho", fraction=1278},
    [58647] = {name = "Ella", fraction=1275},
    [58710] = {name = "Jogu", fraction=1273}
}
Dizzy.TillerRepExaltedAt = 42000


-- March lily, Lovely apple, food they love, etc...
Dizzy.IsTillerItem = function(id)
    if not id then return false end

    if Dizzy.TillerItems[id] then return true else return false end
end


