
Timer = require "lib/hump/timer"
ColorUtil = require "colorutil"
Enums = require "enums"

local Actors, BulletTypes = Enums.Actors, Enums.BulletTypes

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
            xSpacing = 2, -- spacing between rounds
            radius = 16,
            scaling = 2,
        },
        rounds = {},
        total_rounds = 0,
        current_round = 1,
    },
    turn = Actors.PLAYER, -- Actors.PLAYER or Actors.ENEMY
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
            draw = true,
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
            draw = true,
            color = {0.5, 0.5, 1},
        },
        game_over_restart = {
            x = 0.5, -- center of the screen
            y = 0.5, -- center of the screen
            w = 0.2, -- width of button
            h = 0.1, -- height of button
            text = "Restart",
            hovered = false,
            disabled = false,
            pressed = false,
            draw = false, -- initially hidden
            color = {1, 0, 0},
        },
        game_over_quit = {
            x = 0.5, -- center of the screen
            y = 0.6, -- center of the screen
            w = 0.2, -- width of button
            h = 0.1, -- height of button
            text = "Quit",
            hovered = false,
            disabled = false,
            pressed = false,
            draw = false, -- initially hidden
            color = {1, 0, 0},
        },
    },
    images = {

    }
}

local function initial_game_state()
    -- Initialize the game state here
    game.player.health = game.player.max_health
    game.enemy.health = game.enemy.max_health
    game.gun.current_round = 1
    game.gun.rounds = {}
    game.turn = Actors.PLAYER -- Start with player's turn
    game.buttons.shoot.disabled = true
    game.buttons.pass.disabled = true
    game.buttons.game_over_restart.draw = false
    game.buttons.game_over_quit.draw = false
end

local function generate_gun_rounds()
    game.gun.rounds = {} -- reset rounds
     -- pick a random number of live rounds between 1 and 4
    local live_rounds = math.random(1, 4)
    local blank_rounds = math.random(1, 4)
    local total_rounds = live_rounds + blank_rounds

    local make_bullet_base = function(i)
        return {
            type = BulletTypes.LIVE,
            used = false,
            direction = "",
            dmg = 1,
            pos = {
                x = (i - 1) * (game.gun.draw_vars.radius * 2 * game.gun.draw_vars.scaling + game.gun.draw_vars.xSpacing),
                y = love.graphics.getHeight() * game.gun.draw_vars.yStart,
            }, -- initial position
        }
    end

    for i = 1, live_rounds do
        local round = make_bullet_base(i)
        table.insert(game.gun.rounds, round)
    end

    for i = 1, blank_rounds do
        local round = make_bullet_base(i + live_rounds)
        round.type = BulletTypes.BLANK
        round.dmg = 0
        table.insert(game.gun.rounds, round)
    end

    -- find middle position and offset the rounds so they are centered
    local total_width = (game.gun.draw_vars.radius * 2 * game.gun.draw_vars.scaling + game.gun.draw_vars.xSpacing) * total_rounds
    local offset = (love.graphics.getWidth() - total_width) / 2
    for i, round in ipairs(game.gun.rounds) do
        round.pos.x = offset + round.pos.x
    end

    game.gun.total_rounds = total_rounds
    game.gun.current_round = 1 -- reset current round

    -- TODO shuffle the rounds to randomize their order
    -- set buttons to clickable
    game.buttons.shoot.disabled = false
    game.buttons.pass.disabled = false

    print("Gun rounds generated:")
    for i, round in ipairs(game.gun.rounds) do
        print(i, round.type)
    end
end

local function handle_reload()
    -- at the end of all bullets, we reload the gun
    -- reset the rounds and current round
    game.gun.current_round = 1
    game.gun.rounds = {}
    game.gun.total_rounds = 0
    game.buttons.shoot.disabled = true
    game.buttons.pass.disabled = true
    generate_gun_rounds() -- Generate new rounds
end

local function handle_game_over()
    -- Check if either player or enemy is dead
  
    -- Show restart and quit buttons
    game.buttons.game_over_restart.draw = true
    game.buttons.game_over_quit.draw = true
    game.buttons.shoot.disabled = true
    game.buttons.pass.disabled = true
end

local function draw_game_over_text()
    local text = ""
    if game.player.health <= 0 then
        text = "You lose! Try again?"
    elseif game.enemy.health <= 0 then
        text = "You win! Play again?"
    end
    if text == "" then return end -- No game over text to draw

    -- Draw the game over text if applicable
    if game.buttons.game_over_restart.draw then
        local x = love.graphics.getWidth() * 0.5 - 100
        local y = love.graphics.getHeight() * 0.3 - 50
        love.graphics.setColor(1, 1, 1) -- white for text
        love.graphics.printf(text, x, y, 200, "center")
    end
end

local function draw_turn_indicator()
    -- Draw the turn indicator at the top of the screen
    local x = love.graphics.getWidth() * 0.5
    local y = love.graphics.getHeight() * 0.05
    local text = (game.turn == Actors.PLAYER) and "Player's Turn" or "Enemy's Turn"
    love.graphics.setColor(1, 1, 1) -- white for text
    love.graphics.printf(text, x - 50, y, 100, "center")
end

local function draw_gun_rounds()
    -- for current -> total rounds, draw the gun rounds
    -- blanks are blue, bullets are red
    for i, round in ipairs(game.gun.rounds) do
        local color = {1, 1, 1}
        if round.used then
            color = ColorUtil.adjustLightness(color, -0.5) -- darken color if used
        end
        love.graphics.setColor(color)
        local quad = game.images[round.type]
        local scaling = game.gun.draw_vars.scaling
        love.graphics.draw(game.images.yinYangSpritesheet, quad, round.pos.x, round.pos.y, 0, scaling)
        love.graphics.setColor(1, 1, 1) -- Reset color to white
    end
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
        if not button.draw then
            goto continue
        end
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
        ::continue::
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

-- direction is just Actors.PLAYER or Actors.ENEMY and bullet is the object
local function handle_shooting_generic(direction, bullet)
    bullet.used = true
    print("user:", game.turn, "going to:", direction, "bullet:", bullet.type)
    -- depending on direction, let's tween it to the target somewhere, randomly offset left/right
    -- and up/down
    local target_x = (love.graphics.getWidth() * 0.5 + math.random(-50, 50))
    local target_y = (direction == Actors.PLAYER) and (love.graphics.getHeight() * 0.9) or (love.graphics.getHeight() * 0.1 + math.random(-50, 50))
    local tween_duration = 0.2 -- duration of the tween in seconds
    Timer.tween(tween_duration, bullet.pos, {x = target_x, y = target_y}, 'in-linear', function()
        -- Callback after tweening is done, you can add any additional logic here
        bullet.used = true -- mark the bullet as used
        game.gun.current_round = game.gun.current_round + 1
        
        if bullet.type == BulletTypes.LIVE then
            if direction == Actors.PLAYER then
                game.player.health = math.max(0, game.player.health - bullet.dmg)
            elseif direction == Actors.ENEMY then
                game.enemy.health = math.max(0, game.enemy.health - bullet.dmg)
            end
        end

        if game.player.health <= 0 or game.enemy.health <= 0 then
            handle_game_over() -- Check for game over condition
            return
        elseif game.gun.current_round > game.gun.total_rounds then
            handle_reload() -- Reload the gun if all rounds are used
        end

        -- if turn and direction are the same, the actor gets to shoot again
        if game.turn == direction and bullet.type == BulletTypes.BLANK then
            -- no op. but we enable the buttons again for the player to shoot again if it's their turn
            if game.turn == Actors.PLAYER then
                game.buttons.shoot.disabled = false
                game.buttons.pass.disabled = false
            end
        else
            -- we know that an actor shot the other actor, so we switch Actors no matter what
            if game.turn == Actors.PLAYER and game.player.health > 0 and game.enemy.health > 0 then
                game.turn = Actors.ENEMY
                do_enemy_turn() -- handle enemy's turn logic
            else
                game.turn = Actors.PLAYER
                game.buttons.shoot.disabled = false
                game.buttons.pass.disabled = false
            end
        end

        
    end)
end

do_enemy_turn = function()    -- Handle enemy's turn logic here
    -- For simplicity, let's say the enemy always shoots
    local current_round = game.gun.rounds[game.gun.current_round]
    print("Enemy's turn, current round type:", current_round.type)
    handle_shooting_generic(Actors.PLAYER, current_round)
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
        handle_shooting_generic(Actors.ENEMY, current_round)
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
        handle_shooting_generic(Actors.PLAYER, current_round)
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
        -- Check if the game over restart button was pressed
        if game.buttons.game_over_restart.draw and game.buttons.game_over_restart.pressed then
            print("Restart button pressed")
            game.load() -- Restart the game
        end

        -- Check if the game over quit button was pressed
        if game.buttons.game_over_quit.draw and game.buttons.game_over_quit.pressed then
            print("Quit button pressed")
            state = states.menu -- Go back to the menu state
            state.load()
        end
    end
end

local function load_images()
    game.images.yinYangSpritesheet = love.graphics.newImage("assets/sprites/yinyang.png")
    game.images.yinYangSpritesheet:setFilter("nearest", "nearest")
    game.images[BulletTypes.UNKNOWN] = love.graphics.newQuad(0, 0, 32, 32, game.images.yinYangSpritesheet:getDimensions())
    game.images[BulletTypes.LIVE] = love.graphics.newQuad(32, 0, 32, 32, game.images.yinYangSpritesheet:getDimensions())
    game.images[BulletTypes.BLANK] = love.graphics.newQuad(64, 0, 32, 32, game.images.yinYangSpritesheet:getDimensions())


end


game.load = function()
    math.randomseed(os.time())
    -- Load any resources needed for the game here
    load_images() -- Load images for the game
     -- Initialize the game state

    initial_game_state()
    generate_gun_rounds()

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
    draw_game_over_text()
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