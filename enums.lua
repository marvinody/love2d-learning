-- enums.lua

-- Enum for Actors
local Actors = {
    PLAYER = "PLAYER",
    ENEMY = "ENEMY"
}

-- Enum for bullet types
local BulletTypes = {
    LIVE = "LIVE",
    BLANK = "BLANK"
}

return {
    Actors = Actors,
    BulletTypes = BulletTypes
}