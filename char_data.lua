local Enums = require('enums')
local Effect = require('effect')
local Item = require('items')

function printTable(tbl, indent)
    indent = indent or 0
    for key, value in pairs(tbl) do
        local formatting = string.rep("  ", indent) .. tostring(key) .. ": "
        if type(value) == "table" then
            print(formatting)
            printTable(value, indent + 1)
        else
            print(formatting .. tostring(value))
        end
    end
end

local char_data = {
    [Enums.Characters.REIMU_HAKUREI] = {
        name = "Reimu Hakurei",
        description = "The shrine maiden of the Hakurei Shrine.\n+1 HP at the start of each round.",
        effects = {
            Effect:new({
                timing = Enums.EffectTimings.START_OF_ROUND,
                onApply = function(self, game_state)
                    local player = game_state[Enums.Actors.PLAYER]
                    print("Reimu Hakurei effect applied: +1 HP at the start of the round.")
                    print(player.health, player.max_health)
                    if player.health < player.max_health then
                        player.health = math.min(player.health + 1, player.max_health)
                    end
                end,

            })
        }
    },
    [Enums.Characters.MARISA_KIRISAME] = {
        name = "Marisa Kirisame",
        description = "A human magician who loves collecting powerful magic and artifacts.\nTwice as likely to get DMG UP.",
        effects = {
            Effect:new({
                timing = Enums.EffectTimings.PRE_ITEM_GENERATION,
                onApply = function(self, game_state)
                    -- Increase the chance of getting a DMG UP item
                    local player = game_state[Enums.Actors.PLAYER]
                    local item_rates = player.meta.item_rates
                    item_rates[Enums.ItemTypes.DOUBLE_DMG] = item_rates[Enums.ItemTypes.DOUBLE_DMG] * 2
                end,
            })
        }
    },
    [Enums.Characters.YOUMU_KONPAKU] = {
        name = "Youmu Konpaku",
        description = "A half-human, half-ghost swordswoman serving Yuyuko Saigyouji.\nStarts the game with 4 polarity swaps.",
        effects = {
            Effect:new({
                timing = Enums.EffectTimings.START_OF_GAME,
                onApply = function(self, game_state)
                    printTable(game_state)
                    print(game_state[Enums.Actors.PLAYER])
                    for i = 1, 4 do
                        table.insert(game_state[Enums.Actors.PLAYER].items, Item.Polarizer())
                    end
                end,
            })
        }
    },
}

return char_data