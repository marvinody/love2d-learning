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

-- 

local function NewItem (name, type, description, is_enabled_fn, middleware)
    local item = {
        name = name,
        type = type, -- from ItemTypes in enums.lua
        description = description or "",
        sprites = {
            enabled = love.graphics.newImage('assets/sprites/pixel-boy/' .. name .. '-enabled.png'),
            disabled = love.graphics.newImage('assets/sprites/pixel-boy/' .. name .. '-disabled.png'),
        },
        hovered = false,
        pressed = false,
        released = false,
        is_enabled_fn = is_enabled_fn or function() return true end, -- default to always enabled
        middleware = middleware or function() end, -- optional middleware function for additional logic when using the item
        activate = function(self, game_state)
            if self.is_enabled_fn(game_state) then
                -- Perform the action associated with the item here
                self.middleware(game_state) -- Call middleware if provided
                -- remove from inventory by going through the inventory and removing this item
                for i, item in ipairs(game_state.player.items) do
                    if item == self then
                        table.remove(game_state.player.items, i) -- Remove the item from the inventory
                        break -- Exit loop after removing the item
                    end
                end
                
                return true -- Indicate success
            else
                return false -- Indicate failure (not enabled)
            end
        end,
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

local HeartItem = NewItem(
    'heal',
    'consumable', -- Assuming this is a consumable item type
    'Restores 1 heart of health.',
    function(game_state) 
        return game_state.player.health < game_state.player.max_health -- Only enable if health is below max
    end,
    function(game_state)
        game_state.health = math.min(game_state.health + 1, game_state.max_health) -- Restore 1 heart
    end
)


return {
    constants = constants,
    HeartItem = HeartItem,
    get_item_bounds = get_item_bounds,
}

