local game = {
    player = {
        items = {},
        health = 2,
        max_health = 4,
    },
    enemy = {
        items = {},
        health = 3,
        max_health = 4,
    },
    gun = {
        rounds = {},
        total_rounds = 0,
        current_round = 1,
    },
    turn = "player", -- "player" or "enemy"
    buttons = {
        shoot = {
            x = 0.4, -- left side of the screen
            y = 0.8, -- towards the bottom of the screen
            w = 0.1, -- width of button
            h = 0.1, -- height of button
            text = "Shoot",
            hovered = false,
            disabled = true,
            pressed = false,
            color = {0, 1, 0},
        },
        pass = {
            x = 0.6, -- right side of the screen
            y = 0.8, -- towards the bottom of the screen
            w = 0.1, -- width of button
            h = 0.1, -- height of button
            text = "Pass",
            hovered = false,
            disabled = true,
            pressed = false,
            color = {0.5, 0.5, 1},
        },
    }
}

local function generate_gun_rounds()
    -- pick random number for total number of rounds in shotgun
    local total_rounds = math.random(2, 10)
    -- for each shell, randomly choose if it is a bullet or a blank
    game.gun.total_rounds = total_rounds
    game.gun.rounds = {} -- reset rounds
     -- generate rounds
    for i = 1, total_rounds do
        local round_type = math.random(1, 2) -- 1 for bullet, 2 for blank
        if round_type == 1 then
            table.insert(game.gun.rounds, "bullet")
        else
            table.insert(game.gun.rounds, "blank")
        end
    end

    -- TODO shuffle the rounds to randomize their order
    -- set buttons to clickable
    game.buttons.shoot.disabled = false
    game.buttons.pass.disabled = false
end

local function draw_turn_indicator()
    -- Draw the turn indicator at the top of the screen
    local x = love.graphics.getWidth() * 0.5
    local y = love.graphics.getHeight() * 0.05
    local text = (game.turn == "player") and "Player's Turn" or "Enemy's Turn"
    love.graphics.setColor(1, 1, 1) -- white for text
    love.graphics.printf(text, x - 50, y, 100, "center")
end

local function draw_gun_rounds()
    -- for current -> total rounds, draw the gun rounds
    -- blanks are blue, bullets are red
    local x = love.graphics.getWidth() * 0.5
    local y = love.graphics.getHeight() * 0.5
    local radius = 10
    local spacing = 5
    for i = 1, game.gun.total_rounds do
        local color = (game.gun.rounds[i] == "bullet") and {1, 0, 0} or {0, 0, 1}
        love.graphics.setColor(color)
        love.graphics.circle("fill", x + (i - 1) * (radius * 2 + spacing), y, radius)
        -- if it's been used, draw an X through it
        if i < game.gun.current_round then
            love.graphics.setColor(1, 1, 1) -- white for the X
            love.graphics.setLineWidth(2)
            love.graphics.line(x + (i - 1) * (radius * 2 + spacing) - radius, y - radius,
                              x + (i - 1) * (radius * 2 + spacing) + radius, y + radius)
            love.graphics.line(x + (i - 1) * (radius * 2 + spacing) + radius, y - radius,
                              x + (i - 1) * (radius * 2 + spacing) - radius, y + radius)
        end

    end
    love.graphics.setColor(1, 1, 1) -- Reset color to white
end

-- local func to help draw health bar
local function draw_health_bar(xP, yP, health, max_health)
    local x = love.graphics.getWidth() * xP
    local y = love.graphics.getHeight() * yP
    local bar_width = 100
    local bar_height = 10
    -- for each health point, draw a segment of the bar
    for i = 1, max_health do
        local segment_x = x + (i - 1) * (bar_width / max_health)
        local color = i <= health and {0, 1, 0} or {1, 0, 0}
        love.graphics.setColor(color)
        love.graphics.rectangle("fill", segment_x, y, bar_width / max_health - 2, bar_height)
    end
    love.graphics.setColor(1, 1, 1) -- Reset color to white
end

local function draw_buttons()
    -- Draw the buttons for shooting and passing
    for _, button in pairs(game.buttons) do
        local x = love.graphics.getWidth() * button.x - (button.w * love.graphics.getWidth()) / 2
        local y = love.graphics.getHeight() * button.y - (button.h * love.graphics.getHeight()) / 2
        local button_color
        if button.disabled then
            button_color = {0.5, 0.5, 0.5}
        elseif button.pressed then
            button_color = {1, 0, 0}
        elseif button.hovered then
            button_color = {1, 1, 0}
        else
            button_color = button.color
        end

        love.graphics.setColor(button_color) -- Use appropriate color based on state
        love.graphics.rectangle("fill", x, y, button.w * love.graphics.getWidth(), button.h * love.graphics.getHeight())
        love.graphics.setColor(0, 0, 0) -- black for text
        love.graphics.printf(button.text, x, y + (button.h * love.graphics.getHeight() - 20) / 2, button.w * love.graphics.getWidth(), "center")
    end
end

local function handle_button_generic(mx, my, inFn, outFn)
    -- Check if the mouse is over any of the buttons and call the appropriate function
    for _, button in pairs(game.buttons) do
        local x = love.graphics.getWidth() * button.x - (button.w * love.graphics.getWidth()) / 2
        local y = love.graphics.getHeight() * button.y - (button.h * love.graphics.getHeight()) / 2
        if mx >= x and mx <= x + (button.w * love.graphics.getWidth()) and my >= y and my <= y + (button.h * love.graphics.getHeight()) then
            if inFn then inFn(button) end -- Call the in function if provided
        else
            if outFn then outFn(button) end -- Call the out function if provided
        end
    end
end

local function handle_mousemove_buttons(mx, my)
    handle_button_generic(mx, my, 
        function(button)
            button.hovered = true
        end, 
        function(button)
            button.hovered = false
            button.pressed = false -- Reset pressed state if the mouse is dragged out
        end
    )
end

-- Handle mouse press on buttons using the handle_button_generic function
local function handle_mousepressed_buttons(mx, my, button)
    if button == 1 then -- Left mouse button
        handle_button_generic(mx, my, 
            function(btn)
                btn.pressed = true -- Set pressed state to true
            end
        )
    end
end

local function do_enemy_turn()
    -- Handle enemy's turn logic here
    -- For simplicity, let's say the enemy always shoors
    local current_round = game.gun.rounds[game.gun.current_round]
    if current_round == "bullet" then
        -- Enemy hits itself, lose health
        game.enemy.health = math.max(0, game.enemy.health - 1)
    end
    -- Move to the next round
    game.gun.current_round = math.min(game.gun.current_round + 1, game.gun.total_rounds)
    -- Disable buttons if all rounds are used, otherwise enable them for player turn
    if game.gun.current_round > game.gun.total_rounds then
        game.buttons.shoot.disabled = true
        game.buttons.pass.disabled = true
    else
        game.buttons.shoot.disabled = false
        game.buttons.pass.disabled = false
    end
end

local function button_shoot_action()
    -- Handle the shoot button action
    if not game.buttons.shoot.disabled then
        local damage = 1 -- Define the damage value at the top
        local current_round = game.gun.rounds[game.gun.current_round]
        print("Current round idx:", game.gun.current_round)
        print("Current round type:", current_round)
        if current_round == "bullet" then
            -- Player hit the enemy
            game.enemy.health = math.max(0, game.enemy.health - damage)
        end
        -- Move to the next round
        game.gun.current_round = math.min(game.gun.current_round + 1, game.gun.total_rounds)
        -- Disable buttons for enemy turn or all rounds used
        game.buttons.shoot.disabled = true
        game.buttons.pass.disabled = true
        
        -- Switch turn to enemy if player passes
        if game.turn == "player" then
            game.turn = "enemy"
        end
    end
end

local function button_pass_action()
    -- Handle the pass button action
    -- this will shoot the player himself
    -- if it's a blank, player gets to shoot again (pass)
    -- if it's a bullet, player loses health and enemy gets to shoot
    if not game.buttons.pass.disabled then
        local current_round = game.gun.rounds[game.gun.current_round]
        if current_round == "bullet" then
            -- Player hit himself, lose health
            game.player.health = math.max(0, game.player.health - 1)
        end
        -- Move to the next round
        game.gun.current_round = math.min(game.gun.current_round + 1, game.gun.total_rounds)
        -- Disable buttons if all rounds are used
        if game.gun.current_round > game.gun.total_rounds then
            game.buttons.shoot.disabled = true
            game.buttons.pass.disabled = true
        end
    end
end

local function handle_mousereleased_buttons(mx, my, button)
    if button == 1 then -- Left mouse button
        -- Check if the shoot button was pressed
        if game.buttons.shoot.pressed then
            print("Shoot button pressed")
            button_shoot_action()
            game.buttons.shoot.pressed = false -- Reset pressed state after action
        end
        -- Check if the pass button was pressed
        if game.buttons.pass.pressed then
            print("Pass button pressed")
            button_pass_action()
            game.buttons.pass.pressed = false -- Reset pressed state after action
        end
    end
end


game.load = function()
    math.randomseed(os.time())
    -- Load any resources needed for the game here
    generate_gun_rounds()
    print("Gun rounds generated:")
    for i, round in ipairs(game.gun.rounds) do
        print(i, round)
    end
end

game.update = function(dt)
    -- Update the game state here, if needed
end

game.draw = function()
    draw_health_bar(0.5, 0.9, game.player.health, game.player.max_health)
    draw_health_bar(0.5, 0.1, game.enemy.health, game.enemy.max_health)
    draw_gun_rounds()
    draw_buttons()
    draw_turn_indicator()
    
end

game.mousepressed = function(x, y, button, istouch, presses)
    -- Handle mouse press events here
    handle_mousepressed_buttons(x, y, button)

end

game.mousemoved = function(x, y, dx, dy, istouch)
    -- Handle mouse movement events here
    handle_mousemove_buttons(x, y)
end

game.mousereleased = function(x, y, button, istouch, presses)
    -- Handle mouse release events here
    handle_mousereleased_buttons(x, y, button)

end

game.keypressed = function(key, scancode, isrepeat)
    -- Handle key press events here
end

game.resize = function()
    -- Handle resizing of the game here
end

return game