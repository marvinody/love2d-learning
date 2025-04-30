local Enums = require('enums')

local char_select = {
    text_color = { 0, 0, 0 },                -- black
    disabled_text_color = { 0.7, 0.7, 0.7 }, -- gray_70
    background_color = { 0, 0, 0 },          -- black
    selected_text_color = { 0, 0, 0 },       -- black
    selected_background_color = { 1, 1, 0 }  -- yellow5
}

local char_data = require('char_data')

local char_order = {
    Enums.Characters.REIMU_HAKUREI,
    Enums.Characters.MARISA_KIRISAME,
    Enums.Characters.YOUMU_KONPAKU,
}

local local_state = {
    hovered_character = nil,
    selected_character = Enums.Characters.REIMU_HAKUREI, -- Default selected character
    active_buttons = {
        {
            name = "start_game",
            text = "Start",
            x = 7 / 8,
            y = 0.8,
            w = 0.2,
            h = 0.0833,
            hovered = false,
        },
    }
}

local largeFont = love.graphics.newFont(36)


local images = {
    [Enums.Characters.REIMU_HAKUREI] = {
        full = love.graphics.newImage('assets/characters/reimu_hakurei/full.png'),
        head = love.graphics.newImage('assets/characters/reimu_hakurei/headshot.png'),
    },
    [Enums.Characters.MARISA_KIRISAME] = {
        full = love.graphics.newImage('assets/characters/marisa_kirisame/full.png'),
        head = love.graphics.newImage('assets/characters/marisa_kirisame/headshot.png'),
    },
    [Enums.Characters.YOUMU_KONPAKU] = {
        full = love.graphics.newImage('assets/characters/youmu_konpaku/full.png'),
        head = love.graphics.newImage('assets/characters/youmu_konpaku/headshot.png'),
    },
}

-- Function to calculate the screen bounds for each character's head in a grid layout
local generate_head_bounds = function(startX, startY)
    local bounds = {}

    -- Grid layout parameters
    local columns = 3
    local xSpacing = 162 -- Horizontal space between the start of each column cell
    local ySpacing = 162 -- Vertical space between the start of each row cell
    local xMargin = 16
    local yMargin = 16

    -- Offset within each cell where the head image is drawn
    -- These should match the offsets used in drawCharacter
    local drawOffsetX = 0
    local drawOffsetY = 0

    -- Use provided start coordinates or default
    local gridStartX = startX or 100
    local gridStartY = startY or 100

    local currentCol = 1
    local currentRow = 1

    for _, character in ipairs(char_order) do
        local data = images[character]
        if data and data.head then
            -- Calculate the top-left corner of the current grid cell
            local cellX = gridStartX + (currentCol - 1) * (xSpacing + xMargin)
            local cellY = gridStartY + (currentRow - 1) * (ySpacing + yMargin)

            -- Calculate the actual drawing position based on cell position and offset
            local headDrawX = cellX + drawOffsetX
            local headDrawY = cellY + drawOffsetY

            local headWidth = data.head:getWidth()
            local headHeight = data.head:getHeight()

            bounds[character] = {
                x = headDrawX,
                y = headDrawY,
                width = headWidth,
                height = headHeight,
            }

            -- Move to the next column
            currentCol = currentCol + 1
            -- If column exceeds max, reset column and move to the next row
            if currentCol > columns then
                currentCol = 1
                currentRow = currentRow + 1
            end
        end
    end
    return bounds
end

local bounds = generate_head_bounds(100, 100)

char_select.load = function()
    -- Load any resources needed for the char_select here
end

char_select.update = function(dt)
    -- Update the char_select local_state here, if needed
end

local draw_active_buttons = function()
    love.graphics.clear(0.1, 0.1, 0.1) -- Clear the screen with a dark color
    love.graphics.setColor(1, 1, 1)    -- Set color to white for drawing
    -- Example: draw a logo or background image if needed
    -- love.graphics.draw(logo, x, y)
    -- Draw buttons or other UI elements here
    for _, button in ipairs(local_state.active_buttons) do
        local w = button.w * love.graphics.getWidth()
        local h = button.h * love.graphics.getHeight()
        local x = button.x * love.graphics.getWidth() - w / 2  -- Center the button horizontally
        local y = button.y * love.graphics.getHeight() - h / 2 -- Center the button vertically

        if button.disabled then
            love.graphics.setColor(0.5, 0.5, 0.5)                         -- Disabled color
        elseif button.hovered then
            love.graphics.setColor(char_select.selected_background_color) -- Highlight color
        else
            love.graphics.setColor(1, 1, 1)                               -- Normal color
        end

        love.graphics.rectangle('fill', x, y, w, h)
        -- Draw button text or other elements here

        love.graphics.setColor(char_select.text_color)
        local font = love.graphics.getFont()
        local textHeight = font:getHeight()
        local textY = y + (h - textHeight) / 2

        -- Draw the button text centered vertically and horizontally
        love.graphics.printf(button.text, x, textY, w, 'center')    end
end

local mousepressed_active_buttons = function(x, y, button, istouch, presses)
    -- Handle mouse press events for active buttons
    if button == 1 then -- Left mouse button
        for _, btn in ipairs(local_state.active_buttons) do
            local bx = btn.x * love.graphics.getWidth() - (btn.w * love.graphics.getWidth()) / 2
            local by = btn.y * love.graphics.getHeight() - (btn.h * love.graphics.getHeight()) / 2
            local bw = btn.w * love.graphics.getWidth()
            local bh = btn.h * love.graphics.getHeight()
            if x >= bx and x <= (bx + bw) and y >= by and y <= (by + bh) then
                -- Button was clicked, perform the action associated with it
                if btn.name == "start_game" then
                    -- Start the game or transition to the game local_state
                    print("Starting game...")
                    -- Here you would typically change the local_state to the game local_state
                    state = states.game
                    state[Enums.Actors.PLAYER].character = local_state.selected_character
                    state.load() -- Load the game local_state if needed
                end
            end
        end
    end
end

local mousemoved_active_buttons = function(x, y, dx, dy, istouch)
    -- Handle mouse movement events for active buttons
    for _, btn in ipairs(local_state.active_buttons) do
        local bx = btn.x * love.graphics.getWidth() - (btn.w * love.graphics.getWidth()) / 2
        local by = btn.y * love.graphics.getHeight() - (btn.h * love.graphics.getHeight()) / 2
        local bw = btn.w * love.graphics.getWidth()
        local bh = btn.h * love.graphics.getHeight()

        if x >= bx and x <= (bx + bw) and y >= by and y <= (by + bh) then
            -- Mouse is over the button, you can change its local_state or appearance here
            -- e.g., highlight the button or show a tooltip
            btn.hovered = true
        else
            -- Mouse is not over the button, reset its local_state
            btn.hovered = false
        end
    end
end

local function draw_char_data()
    -- Draw the character data (name and description) for the hovered or selected character
    local character = local_state.hovered_character or local_state.selected_character
    if character then
        local data = char_data[character]
        if data then
            -- Get bounds for the first character
            local first_char, third_char = char_order[1], char_order[3]
            local first_bounds, third_bounds = bounds[first_char], bounds[third_char]

            local leftBound = first_bounds.x
            local rightBound = third_bounds.x + third_bounds.width

            local available_width = rightBound - leftBound

            -- Set text color to white
            love.graphics.setColor(1, 1, 1)

            -- Define the Y position for the name and description (adjust as needed)
            local descY = first_bounds.y + first_bounds.height + 10 -- Below the first character's head

            -- Draw the character description below the name
            love.graphics.setFont(love.graphics.newFont(24)) -- Smaller font for description
            love.graphics.printf(data.description, leftBound, descY, available_width, 'center')
        end
    end
end

local function draw_char_full()
    -- Draw the full character image for the selected character
    local character = local_state.hovered_character or local_state.selected_character
    local data = images[character]
    if data and data.full then
        -- Get bounds for the first character
        local x = 660
        local y = 100

        -- Draw the full character image at the position of the first character's head
        love.graphics.draw(data.full, x, y, nil, 0.25, 0.25)
    end
end

local function draw_heads(x, y)
    for _, character in ipairs(char_order) do
        local data = images[character]
        if data and data.head then
            local headBounds = bounds[character]
            if headBounds then
                local borderThickness = 4 -- Define the thickness of the border

                -- Draw border for selected character
                if local_state.selected_character == character then
                    -- Set color for selected border (e.g., semi-transparent green)
                    love.graphics.setColor(0, 1, 0, 0.8)
                    -- Draw a filled rectangle behind the head, expanded by the border thickness
                    love.graphics.rectangle("fill",
                        headBounds.x - borderThickness,
                        headBounds.y - borderThickness,
                        headBounds.width + 2 * borderThickness,
                        headBounds.height + 2 * borderThickness)
                    -- Reset color to white for drawing the head
                    -- Draw border for hovered character (if not also selected)
                elseif local_state.hovered_character == character then
                    -- Set color for hovered border (e.g., semi-transparent blue)
                    love.graphics.setColor(0, 0, 1, 0.6)
                    -- Draw a filled rectangle behind the head, expanded by the border thickness
                    love.graphics.rectangle("fill",
                        headBounds.x - borderThickness,
                        headBounds.y - borderThickness,
                        headBounds.width + 2 * borderThickness,
                        headBounds.height + 2 * borderThickness)
                    -- Reset color to white for drawing the head
                end

                love.graphics.setColor(1, 1, 1)
                -- Draw the character head image itself
                love.graphics.draw(data.head, headBounds.x, headBounds.y)

                -- Optionally draw a thin rectangle outline around the head for debugging or visual separation
                -- love.graphics.setColor(1, 0, 0, 0.5) -- Semi-transparent red for debug
                -- love.graphics.rectangle("line", headBounds.x, headBounds.y, headBounds.width, headBounds.height)
                -- love.graphics.setColor(1, 1, 1) -- Reset color to white
            end
        end
    end
end

local function capitalize(str)
    -- Capitalize the first letter of each word in the string
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

local function draw_char_name()
    -- draw the name of the hovered or selected character
    local character = local_state.hovered_character or local_state.selected_character
    if character then
        -- Get bounds for the first character
        local first_char, third_char = char_order[1], char_order[3]
        local first_bounds, third_bounds = bounds[first_char], bounds[third_char]

        local leftBound = first_bounds.x
        local rightBound = third_bounds.x + third_bounds.width

        local available_width = rightBound - leftBound

        -- Format the character name for display
        local name = capitalize(character:gsub("_", " ")) -- Replace underscores with spaces

        -- Set text color to white
        love.graphics.setColor(1, 1, 1)

        -- Define the Y position for the text (adjust as needed)
        local textY = 50

        -- Draw the character name centered within the calculated horizontal bounds
        love.graphics.setFont(largeFont)
        love.graphics.printf(name, leftBound, textY, available_width, 'center')
    end
end


char_select.draw = function()
    love.graphics.clear(0.1, 0.1, 0.1) -- Clear the screen with a dark color
    love.graphics.setColor(1, 1, 1)    -- Set color to white for drawing
    local x, y = 100, 100

    draw_active_buttons()
    draw_heads(x, y)
    draw_char_name()
    draw_char_full()
    draw_char_data()


    -- Draw any additional UI elements here
end

char_select.mousepressed = function(x, y, button, istouch, presses)
    -- Handle mouse press events here
    if button == 1 then -- Left mouse button
        -- Iterate through the bounds of each character head
        for character, headBounds in pairs(bounds) do
            -- Check if the mouse click is within the bounds of the current character head
            if x >= headBounds.x and x <= headBounds.x + headBounds.width and
                y >= headBounds.y and y <= headBounds.y + headBounds.height then
                -- The mouse click is on this character's head
                local_state.selected_character = character
                break -- Exit loop after selecting a character
            end
        end
    end

    mousepressed_active_buttons(x, y, button, istouch, presses)
end

char_select.mousemoved = function(x, y, dx, dy, istouch)
    -- Iterate through the bounds of each character head
    local hovered = false
    for character, headBounds in pairs(bounds) do
        -- Check if the mouse cursor is within the bounds of the current character head
        if x >= headBounds.x and x <= headBounds.x + headBounds.width and
            y >= headBounds.y and y <= headBounds.y + headBounds.height then
            -- The mouse is hovering over this character's head
            -- Add logic here for hover effects, like highlighting the character
            -- For example: print("Hovering over character:", character)
            if local_state.selected_character ~= character then
                local_state.hovered_character = character
                -- Optionally, you can add logic to update the UI or highlight the selected character
                hovered = true
            end
        else
            -- The mouse is not hovering over this character's head
            -- Add logic here to remove hover effects if necessary
        end
    end

    -- If no character is hovered, reset the hovered character
    if not hovered then
        local_state.hovered_character = nil
    end

    mousemoved_active_buttons(x, y, dx, dy, istouch)
end

char_select.mousereleased = function(x, y, button, istouch, presses)
    -- Handle mouse release events here
end

char_select.keypressed = function(key, scancode, isrepeat)
    -- Handle key press events here

    -- Check if either left or right Alt key is pressed
    if love.keyboard.isDown('lalt') or love.keyboard.isDown('ralt') then
        -- Get current mouse position
        local x, y = love.mouse.getPosition()
        -- Get screen dimensions
        local screenWidth = love.graphics.getWidth()
        local screenHeight = love.graphics.getHeight()

        -- Calculate percentages
        local xPercent = (x / screenWidth) * 100
        local yPercent = (y / screenHeight) * 100

        -- Log the coordinates and percentages
        print(string.format("Mouse Position: (%d, %d) - Percentages: (%.2f%%, %.2f%%)", x, y, xPercent, yPercent))
    end
end

char_select.resize = function()
    -- Handle resizing of the char_select here
end

return char_select
