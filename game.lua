
Timer = require "lib/hump/timer"
ColorUtil = require "colorutil"

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
        draw_vars = {
            xStart = 0.5, -- center of the screen
            yStart = 0.5, -- center of the screen
            xSpacing = 5, -- spacing between rounds
            radius = 10,
        },
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
        local round = { 
            type = (round_type == 1) and "bullet" or "blank",
            used = false,
            direction = "",
            dmg = 1,
            pos = {
                x = love.graphics.getWidth() * game.gun.draw_vars.xStart + (i - 1) * (game.gun.draw_vars.radius * 2 + game.gun.draw_vars.xSpacing),
                y = love.graphics.getHeight() * game.gun.draw_vars.yStart 
            }, -- initial position
        }
        table.insert(game.gun.rounds, round)
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
    local radius = game.gun.draw_vars.radius
    local spacing = game.gun.draw_vars.xSpacing
    for i, round in ipairs(game.gun.rounds) do
        local color = (round.type == "bullet") and {1, 0, 0} or {0, 0, 1}
        if round.used then
            color = ColorUtil.adjustLightness(color, -0.5) -- darken color if used
        end
        love.graphics.setColor(color)
        love.graphics.circle("fill", round.pos.x, round.pos.y, radius)
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

local do_enemy_turn -- forward declaration for enemy turn logic

-- direction is just "player" or "enemy" and bullet is the object
local function handle_shooting_generic(direction, bullet)
    bullet.used = true


    -- depending on direction, let's tween it to the target somewhere, randomly offset left/right
    -- and up/down
    local target_x = (love.graphics.getWidth() * 0.5 + math.random(-50, 50))
    local target_y = (direction == "player") and (love.graphics.getHeight() * 0.9) or (love.graphics.getHeight() * 0.1 + math.random(-50, 50))
    print("Tweening bullet to target:", target_x, target_y)
    local tween_duration = 0.2 -- duration of the tween in seconds
    Timer.tween(tween_duration, bullet.pos, {x = target_x, y = target_y}, 'in-linear', function()
        -- Callback after tweening is done, you can add any additional logic here
        bullet.used = true -- mark the bullet as used
        game.gun.current_round = math.min(game.gun.current_round + 1, game.gun.total_rounds)
        
        if bullet.type == "bullet" then
            if direction == "player" then
                game.player.health = math.max(0, game.player.health - bullet.dmg)
            elseif direction == "enemy" then
                game.enemy.health = math.max(0, game.enemy.health - bullet.dmg)
            end
        end

        -- if turn and direction are the same, the actor gets to shoot again
        if game.turn == direction and bullet.type == "blank" then
            -- no op. but we enable the buttons again for the player to shoot again if it's their turn
            if game.turn == "player" then
                game.buttons.shoot.disabled = false
                game.buttons.pass.disabled = false
            end
        else
            -- we know that an actor shot the other actor, so we switch turns no matter what
            if game.turn == "player" then
                game.turn = "enemy"
                do_enemy_turn() -- handle enemy's turn logic
            else
                game.turn = "player"
                game.buttons.shoot.disabled = false
                game.buttons.pass.disabled = false
            end
        end

        
    end)
end

do_enemy_turn = function()    -- Handle enemy's turn logic here
    -- For simplicity, let's say the enemy always shoors
    local current_round = game.gun.rounds[game.gun.current_round]
    print("Enemy's turn, current round type:", current_round.type)
    handle_shooting_generic("player", current_round)
end

local function button_shoot_action()
    -- Handle the shoot button action
    if not game.buttons.shoot.disabled then
        game.buttons.shoot.disabled = true
        game.buttons.pass.disabled = true
        local current_round = game.gun.rounds[game.gun.current_round]
        print("Current round idx:", game.gun.current_round)
        print("Current round type:", current_round.type)
        -- always towards enemy since shoot
        handle_shooting_generic("enemy", current_round)
    end
end

local function button_pass_action()
    -- Handle the pass button action
    -- this will shoot the player himself
    -- if it's a blank, player gets to shoot again (pass)
    -- if it's a bullet, player loses health and enemy gets to shoot
    if not game.buttons.pass.disabled then
        game.buttons.shoot.disabled = true
        game.buttons.pass.disabled = true
        local current_round = game.gun.rounds[game.gun.current_round]
        handle_shooting_generic("player", current_round)
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
        print(i, round.type)
    end
end

game.update = function(dt)
    -- Update the game state here, if needed
    Timer.update(dt)
end

game.draw = function()
    draw_gun_rounds()
    draw_buttons()
    draw_turn_indicator()
    draw_health_bar(0.5, 0.9, game.player.health, game.player.max_health)
    draw_health_bar(0.5, 0.1, game.enemy.health, game.enemy.max_health)
    
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