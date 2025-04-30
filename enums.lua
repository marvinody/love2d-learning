-- enums.lua

-- Enum for Actors
local Actors = {
    PLAYER = "PLAYER",
    ENEMY = "ENEMY"
}

local Characters = {
    REIMU_HAKUREI = "REIMU_HAKUREI",
    MARISA_KIRISAME = "MARISA_KIRISAME",
    YOUMU_KONPAKU = "YOUMU_KONPAKU",
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
    VISION = "VISION", -- Reveals the next bullets
}

local EffectTimings = {
    START_OF_GAME = "START_OF_GAME",
    START_OF_ROUND = "START_OF_ROUND", -- a round is once the gun is reloaded
    START_OF_EVERY_TURN = "START_OF_EVERY_TURN",
    START_OF_PLAYER_TURN = "START_OF_PLAYER_TURN",
    START_OF_ENEMY_TURN = "START_OF_ENEMY_TURN",
    PRE_ITEM_GENERATION = "PRE_ITEM_GENERATION",
    POST_ITEM_GENERATION = "POST_ITEM_GENERATION",
    BULLET_GENERATION = "BULLET_GENERATION",
}

return {
    Actors = Actors,
    BulletTypes = BulletTypes,
    ItemTypes = ItemTypes,
    Characters = Characters,
    EffectTimings = EffectTimings,
}
