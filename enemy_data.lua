local Enums = require('enums')
local Effect = require('effect')
local Item = require('items')

local char_data = {
    [Enums.Enemies.SAGUME_KISHIN] = {
        name = "Sagume Kishin",
        effects = {},
        max_hp = 6,
        text = {
            [Enums.TextTimings.ENTRANCE] = {
                "Hehe, let's let our attacks talk!",
            },
            [Enums.TextTimings.HIT_FOR_FIRST_TIME] = {
                "Ouch! That stings a bit!",
            },
            [Enums.TextTimings.EXIT] = {
                "Why didn't I overturn this fate...?",
            },
        }
    },
}

return char_data