local menu = {
    buttons = {},
    active_buttons = {
        {
            name = "start_game",
            text = "Start Game",
            x = 0.1875, -- 150/800
            y = 0.8, -- 480/600
            w = 0.625, -- 500/800
            h = 0.0833, -- 50/600
            hovered = false,
        }
    },
    text_color = {0, 0, 0}, -- black
    disabled_text_color = {0.7, 0.7, 0.7}, -- gray_70
    background_color = {0, 0, 0}, -- black
    selected_text_color = {0, 0, 0}, -- black
    selected_background_color = {1, 1, 0} -- yellow5
}

menu.load = function()
    -- Load any resources needed for the menu here
end

menu.update = function(dt)
    -- Update the menu state here, if needed
end

menu.draw = function()
    -- Draw the menu here
    love.graphics.clear(0.1, 0.1, 0.1) -- Clear the screen with a dark color
    love.graphics.setColor(1, 1, 1) -- Set color to white for drawing
    -- Example: draw a logo or background image if needed
    -- love.graphics.draw(logo, x, y)
    -- Draw buttons or other UI elements here
    for _, button in ipairs(menu.active_buttons) do
        local x = button.x * love.graphics.getWidth()
        local y = button.y * love.graphics.getHeight()
        local w = button.w * love.graphics.getWidth()
        local h = button.h * love.graphics.getHeight()
        
        if button.disabled then
            love.graphics.setColor(0.5, 0.5, 0.5) -- Disabled color
        elseif button.hovered then
            love.graphics.setColor(menu.selected_background_color) -- Highlight color
        else
            love.graphics.setColor(1, 1, 1) -- Normal color
        end
        
        love.graphics.rectangle('fill', x, y, w, h)
        -- Draw button text or other elements here

        love.graphics.setColor(menu.text_color) -- Set text color
        love.graphics.printf(button.text, x, y + (h - 20) / 2, w, 'center') -- Centered text

    end
    -- Example: draw a title or instructions
    love.graphics.setColor(1, 1, 1) -- Reset color to white
    love.graphics.print("Menu Title", 10, 10) -- Draw title at the top left
    -- Add any other UI elements as needed
    -- e.g., instructions, credits, etc.
    -- love.graphics.print("Press Enter to Start", 10, 30)
end


menu.mousepressed = function(x, y, button, istouch, presses)
    -- Handle mouse press events here
    if button == 1 then -- Left mouse button
        for _, btn in ipairs(menu.active_buttons) do
            local bx = btn.x * love.graphics.getWidth()
            local by = btn.y * love.graphics.getHeight()
            local bw = btn.w * love.graphics.getWidth()
            local bh = btn.h * love.graphics.getHeight()
            
            if x >= bx and x <= (bx + bw) and y >= by and y <= (by + bh) then
                -- Button was clicked, perform the action associated with it
                if btn.name == "start_game" then
                    -- Start the game or transition to the game state
                    print("Starting game...")
                    -- Here you would typically change the state to the game state
                    state = states.game
                    state.load() -- Load the game state if needed
                end
            end
        end
    end
end

menu.mousemoved = function(x, y, dx, dy, istouch)
    -- Handle mouse movement events here
    -- Check if the mouse is over any buttons and update their state if needed
    for _, button in ipairs(menu.active_buttons) do
        local bx = button.x * love.graphics.getWidth()
        local by = button.y * love.graphics.getHeight()
        local bw = button.w * love.graphics.getWidth()
        local bh = button.h * love.graphics.getHeight()
        
        if x >= bx and x <= (bx + bw) and y >= by and y <= (by + bh) then
            -- Mouse is over the button, you can change its state or appearance here
            -- e.g., highlight the button or show a tooltip
            button.hovered = true
        else
            -- Mouse is not over the button, reset its state
            button.hovered = false
        end
    end
    -- You can also handle dragging or other mouse interactions here
end

menu.mousereleased = function(x, y, button, istouch, presses)
    -- Handle mouse release events here
end

menu.keypressed = function(key, scancode, isrepeat)
    -- Handle key press events here
end

menu.resize = function()
    -- Handle resizing of the menu here
end

return menu