-- enums.lua

-- Enum for Actors
local Actors = {
    PLAYER = "PLAYER",
    ENEMY = "ENEMY"
}

-- Enum for bullet types
local BulletTypes = {
    LIVE = "LIVE",
    BLANK = "BLANK",
    UNKNOWN = "UNKNOWN" -- just for rendering
}

local ItemTypes = {
    HEAL_ONE = "HEAL_ONE",     -- Heals 1 HP
    DOUBLE_DMG = "DOUBLE_DMG", -- Doubles damage for the next attack
    SKIP_TURN = "SKIP_TURN", -- Skips the next player's turn
    POLARIZER = "POLARIZER", -- Changes the polarity of the next bullet
}

return {
    Actors = Actors,
    BulletTypes = BulletTypes,
    ItemTypes = ItemTypes,
}
