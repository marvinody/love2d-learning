Enums = require('enums')
Text = require('text')

local ITEM_PIXEL_SIZE = 24
local ITEM_DRAW_SIZE = 64

local constants = {
    ITEM_PIXEL_WIDTH = ITEM_PIXEL_SIZE,
    ITEM_PIXEL_HEIGHT = ITEM_PIXEL_SIZE,
    ITEM_DRAW_WIDTH = ITEM_DRAW_SIZE,
    ITEM_DRAW_WIDTH_SPACING = 8,
    ITEM_DRAW_HEIGHT = ITEM_DRAW_SIZE,
    ITEM_DRAW_SCALE = ITEM_DRAW_SIZE / ITEM_PIXEL_SIZE,
    MAX_ITEMS = 8,
    ITEM_BORDER_COLOR = { 0.8, 0.8, 0.8 },
}

local text_box_font = love.graphics.newFont(20)

local function NewItem(name, type, description, is_enabled_fn, middleware, actor)
    local item = {
        name = name,
        type = type, -- from ItemTypes in enums.lua
        description = description or "",
        sprites = {
            enabled = love.graphics.newImage('assets/sprites/pixel-boy/' .. type:lower() .. '-enabled.png'),
            disabled = love.graphics.newImage('assets/sprites/pixel-boy/' .. type:lower() .. '-disabled.png'),
        },
        owner = actor,
        hovered = false,
        pressed = false,
        is_enabled_fn = function(self, game_state)
            return game_state.turn == self.owner and is_enabled_fn(game_state) -- Check if the item is enabled
        end,
        middleware = middleware or function() end,                   -- optional middleware function for additional logic when using the item
        activate = function(self, game_state)
            if self:is_enabled_fn(game_state) then
                -- Perform the action associated with the item here
                self.middleware(game_state) -- Call middleware if provided
                -- remove from inventory by going through the inventory and removing this item
                for i, item in ipairs(game_state.player.items) do
                    if item == self then
                        table.remove(game_state.player.items, i) -- Remove the item from the inventory
                        break                                    -- Exit loop after removing the item
                    end
                end

                return true -- Indicate success
            else
                print("Item is not enabled.")
                return false -- Indicate failure (not enabled)
            end
        end,
        draw_text_box = function(self)
            local y = 0.15
            if self.owner == Enums.Actors.ENEMY then
                y = 0.85
            end

            local width = 0.9 * love.graphics.getWidth()
            local height = 0.2 * love.graphics.getHeight()
            local x = 0.05 * love.graphics.getWidth()
            y = y * love.graphics.getHeight()
            local color = { r = 1, g = 1, b = 1 } -- White color for text
            Text.write_text_box(self.description, x, y, width, height, text_box_font, color)
        end
    }
    item.sprites.enabled:setFilter('nearest', 'nearest')
    item.sprites.disabled:setFilter('nearest', 'nearest')
    return item
end

local function get_item_bounds(start_x, start_y)
    local bounds = {}
    for i = 1, constants.MAX_ITEMS do
        local item_x = start_x + (i - 1) * (constants.ITEM_DRAW_WIDTH + constants.ITEM_DRAW_WIDTH_SPACING)
        local item_y = start_y


        bounds[i] = {
            x = item_x,
            y = item_y,
            width = constants.ITEM_DRAW_WIDTH,
            height = constants.ITEM_DRAW_HEIGHT,
        }
    end

    return bounds
end

local HeartItem = function(actor)
    return NewItem(
        '1-UP',
        Enums.ItemTypes.HEAL_ONE,
        'Restores 1 heart of health.',
        function(game_state)
            return game_state.player.health < game_state.player.max_health -- Only enable if health is below max
        end,
        function(game_state)
            game_state.player.health = math.min(game_state.player.health + 1, game_state.player.max_health) -- Restore 1 heart
        end,
        actor or Enums.Actors.PLAYER
    )
end

local DoubleDmg = function(actor)
    return NewItem(
        'Double Dealing Damage',
        Enums.ItemTypes.DOUBLE_DMG,
        'Doubles damage for the next attack. Wasted if next attack is a blank.',
        function(game_state)
            return true -- Always enabled for simplicity
        end,
        function(game_state)
            local current_round = game_state.gun.rounds[game_state.gun.current_round]
            current_round.dmg = current_round.dmg * 2 -- Double the damage for the current roun
        end,
        actor or Enums.Actors.PLAYER
    )
end


return {
    constants = constants,
    HeartItem = HeartItem,
    DoubleDmg = DoubleDmg,
    get_item_bounds = get_item_bounds,

}
