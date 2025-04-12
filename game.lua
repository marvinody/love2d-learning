Timer = require "lib/hump/timer"
Items = require "items"
ColorUtil = require "colorutil"
Enums = require "enums"
Text = require "text"
local PLAYER, ENEMY = Enums.Actors.PLAYER, Enums.Actors.ENEMY

local Actors, BulletTypes = Enums.Actors, Enums.BulletTypes
local draw_vars = {
    gun = {
        xStart = 0.5, -- center of the screen
        yStart = 0.5, -- center of the screen
        xSpacing = 2, -- spacing between rounds
        radius = 16,
        scaling = 2,
    },
    buttons = {
        shoot = {
            x = 0.1,  -- left side of the screen
            y = 0.75, -- towards the bottom of the screen
            w = 0.1,  -- width of button
            h = 0.1,  -- height of button
            text = "Shoot",
            color = { 0, 1, 0 },
        },
        pass = {
            x = 0.21, -- right side of the screen
            y = 0.75, -- towards the bottom of the screen
            w = 0.1,  -- width of button
            h = 0.1,  -- height of button
            text = "Pass",
            color = { 0.5, 0.5, 1 },
        },
        game_over_restart = {
            x = 0.5, -- center of the screen
            y = 0.5, -- center of the screen
            w = 0.2, -- width of button
            h = 0.1, -- height of button
            text = "Restart",
            color = { 1, 0, 0 },
        },
        game_over_quit = {
            x = 0.5, -- center of the screen
            y = 0.6, -- center of the screen
            w = 0.2, -- width of button
            h = 0.1, -- height of button
            text = "Quit",
            color = { 1, 0, 0 },
        },
    }
}

local game = {
    [PLAYER] = {
        items = {
            Items.HeartItem(),
            Items.DoubleDmg(),
            Items.DoubleDmg(),
            Items.HeartItem(),
            Items.SkipTurn(),
            Items.SkipTurn(),
        },
        health = 2,
        max_health = 4,
        meta = {
            next_turn_skip = false,
        }
    },
    [ENEMY] = {
        items = {},
        health = 3,
        max_health = 4,
        meta = {
            next_turn_skip = false,
        }
    },
    gun = {
        rounds = {},
        total_rounds = 0,
        current_round = 1,
    },
    turn = Actors.PLAYER, -- Actors.PLAYER or Actors.ENEMY
    buttons = {
        shoot = {
            hovered = false,
            disabled = true,
            pressed = false,
            draw = true,
        },
        pass = {
            hovered = false,
            disabled = true,
            pressed = false,
            draw = true,
        },
        game_over_restart = {
            hovered = false,
            disabled = false,
            pressed = false,
            draw = false, -- initially hidden
        },
        game_over_quit = {
            hovered = false,
            disabled = false,
            pressed = false,
            draw = false, -- initially hidden
        },
    },
    images = {

    }
}

local function initial_game_state()
    -- Initialize the game state here
    game[PLAYER].health = game[PLAYER].max_health
    game[ENEMY].health = game[ENEMY].max_health
    game.gun.current_round = 1
    game.gun.rounds = {}
    game.turn = Actors.PLAYER -- Start with player's turn
    game.buttons.shoot.disabled = true
    game.buttons.pass.disabled = true
    game.buttons.game_over_restart.draw = false
    game.buttons.game_over_quit.draw = false
end

local function assign_default_xy_to_rounds(total_rounds)
    -- find middle position and offset the rounds so they are centered
    local total_sprite_width = (draw_vars.gun.radius * 2 * draw_vars.gun.scaling) * total_rounds
    local total_spacing = draw_vars.gun.xSpacing * (total_rounds - 1)
    local total_width = total_sprite_width + total_spacing

    local offset = (love.graphics.getWidth() - total_width) / 2
    for i, round in ipairs(game.gun.rounds) do
        local x = (i - 1) * (draw_vars.gun.radius * 2 * draw_vars.gun.scaling + draw_vars.gun.xSpacing)
        local y = love.graphics.getHeight() * draw_vars.gun.yStart
        round.pos.x = offset + x + draw_vars.gun.radius * draw_vars.gun.scaling
        round.pos.y = y
        round.pos.default_x = round.pos.x
        round.pos.default_y = round.pos.y
    end
end

local function shuffle_gun_rounds()
    -- shuffle the rounds
    for i = #game.gun.rounds, 2, -1 do
        local j = math.random(i)
        game.gun.rounds[i], game.gun.rounds[j] = game.gun.rounds[j], game.gun.rounds[i]
    end
    assign_default_xy_to_rounds(#game.gun.rounds)
end


local function generate_gun_rounds(done)
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
                x = 0,
                y = 0,
                default_x = 0,
                default_y = 0,
            }, -- initial position
            show_type = true,
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

    -- make it look more organic to player
    shuffle_gun_rounds()

    local function activate_play()
        -- hide the actual order by shuffling the rounds again
        shuffle_gun_rounds()

        game.gun.total_rounds = total_rounds
        game.gun.current_round = 1 -- reset current round

        -- TODO shuffle the rounds to randomize their order
        -- set buttons to clickable
        game.buttons.shoot.disabled = false
        game.buttons.pass.disabled = false

        if done then done() end -- Call the done function if provided
    end


    local function expand_rounds()
        for i, round in ipairs(game.gun.rounds) do
            round.show_type = false
            Timer.tween(0.2, round.pos, { x = round.pos.default_x, y = round.pos.default_y }, 'in-out-cubic')
        end
        Timer.after(0.2, activate_play)
    end

    local function collapse_rounds()
        local middle_x = love.graphics.getWidth() * 0.5

        for i, round in ipairs(game.gun.rounds) do
            Timer.tween(0.2, round.pos, { x = middle_x }, 'in-out-cubic')
        end
        Timer.after(0.2, expand_rounds)
    end

    -- show them for 2 seconds
    Timer.after(2, collapse_rounds)

    print("Gun rounds generated:")
    for i, round in ipairs(game.gun.rounds) do
        print(i, round.type)
    end
end

local function handle_reload(done)
    -- at the end of all bullets, we reload the gun
    -- reset the rounds and current round
    game.gun.current_round = 1
    game.gun.rounds = {}
    game.gun.total_rounds = 0
    game.buttons.shoot.disabled = true
    game.buttons.pass.disabled = true
    generate_gun_rounds(done) -- Generate new rounds

    Items.generate_items(game, PLAYER, 2) -- Generate items for player
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
    if game[PLAYER].health <= 0 then
        text = "You lose! Try again?"
    elseif game[ENEMY].health <= 0 then
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

local function draw_debug_grid()
    -- Draw a grid for debugging purposes
    local grid_count = 20 -- Number of grid cells along the Y-axis
    local screen_height = love.graphics.getHeight()
    local screen_width = love.graphics.getWidth()
    local grid_size = screen_height / grid_count -- Calculate grid size to make squares

    love.graphics.setColor(0.5, 0.5, 0.5)        -- gray for grid lines
    for x = 0, screen_width, grid_size do
        love.graphics.line(x, 0, x, screen_height)
    end
    for y = 0, screen_height, grid_size do
        love.graphics.line(0, y, screen_width, y)
    end
end

local background = {
    layer1 = nil,
    layer2 = nil,
    layer1_width = 0,
    layer1_height = 0,
    layer2_width = 0,
    layer2_height = 0,
    scale = 5, -- Scaling factor for the background
}

local function load_background()
    -- Load images once and calculate their scaled dimensions
    background.layer1 = love.graphics.newImage("assets/sprites/bg_layer1.png")
    background.layer2 = love.graphics.newImage("assets/sprites/bg_layer2.png")
    background.layer1:setFilter("nearest", "nearest")
    background.layer2:setFilter("nearest", "nearest")

    background.layer1_width = background.layer1:getWidth() * background.scale
    background.layer1_height = background.layer1:getHeight() * background.scale
    background.layer2_width = background.layer2:getWidth() * background.scale
    background.layer2_height = background.layer2:getHeight() * background.scale
end

local function draw_background()
    local lg = love.graphics
    local lt = love.timer
    local screen_width = lg.getWidth()
    local screen_height = lg.getHeight()

    -- Speeds for parallax effect
    local layer1_speed = 5
    local layer2_speed = 17

    -- Calculate offsets based on time
    local time = lt.getTime()
    local offset_x1 = time * layer1_speed % background.layer1_width
    local offset_y1 = time * layer1_speed % background.layer1_height
    local offset_x2 = time * layer2_speed % background.layer2_width
    local offset_y2 = time * layer2_speed % background.layer2_height

    -- Calculate the number of tiles needed to cover the screen
    local tiles_x1 = math.ceil(screen_width / background.layer1_width) + 1
    local tiles_y1 = math.ceil(screen_height / background.layer1_height) + 1
    local tiles_x2 = math.ceil(screen_width / background.layer2_width) + 1
    local tiles_y2 = math.ceil(screen_height / background.layer2_height) + 1

    -- Draw layer 1
    lg.setColor(1, 1, 1)
    for x = -1, tiles_x1 do
        for y = -1, tiles_y1 do
            lg.draw(
                background.layer1,
                x * background.layer1_width - offset_x1,
                y * background.layer1_height - offset_y1,
                0,
                background.scale,
                background.scale
            )
        end
    end

    -- Draw layer 2 with parallax effect
    for x = -1, tiles_x2 do
        for y = -1, tiles_y2 do
            lg.draw(
                background.layer2,
                x * background.layer2_width + offset_x2,
                y * background.layer2_height - offset_y2,
                0,
                background.scale,
                background.scale
            )
        end
    end
end

local function draw_gun_rounds()
    -- for current -> total rounds, draw the gun rounds
    local live_rounds = 0
    local blank_rounds = 0
    for i, round in ipairs(game.gun.rounds) do
        local color = { 1, 1, 1 }
        if round.used then
            color = {0.5, 0.5, 0.5}
        end
        love.graphics.setColor(color)
        local type_quad = game.images[round.type]
        local hidden_quad = game.images[BulletTypes.UNKNOWN]
        local quad = (round.used or round.show_type) and type_quad or hidden_quad
        local scaling = draw_vars.gun.scaling
        local radius = draw_vars.gun.radius

        love.graphics.draw(game.images.yinYangSpritesheet, quad, round.pos.x, round.pos.y, 0, scaling, nil, radius,
            radius)

        -- Draw a rectangle around the sprite to visualize borders
        -- love.graphics.setColor(1, 0, 0)    -- red for the border
        -- local sprite_width = 32 * scaling  -- assuming the sprite width is 32
        -- local sprite_height = 32 * scaling -- assuming the sprite height is 32
        -- -- Adjust the position by subtracting the radius
        -- love.graphics.rectangle("line", round.pos.x - 32, round.pos.y - 32, sprite_width, sprite_height)
        -- love.graphics.setColor(1, 1, 1) -- Reset color to white
    end
end

-- local func to help draw health bar
local function draw_health_bar(xP, yP, health, max_health)
    local x = love.graphics.getWidth() * xP
    local y = love.graphics.getHeight() * yP
    local heart_size = 32
    local heart_scaling = 2
    -- for each health point, draw a segment of the bar
    for i = 1, max_health do
        local segment_x = x + (i - 1) * (heart_size * heart_scaling) -- calculate x position for each heart
        local sprite = i <= health and game.images.heart_filled or game.images.heart_empty
        love.graphics.setColor(1, 1, 1)                              -- white for heart
        love.graphics.draw(sprite, segment_x, y, 0, heart_scaling, heart_scaling, heart_size / 2, heart_size / 2)
    end
    love.graphics.setColor(1, 1, 1) -- Reset color to white
end

local function draw_buttons()
    -- Draw the buttons for shooting and passing
    for idx, button in pairs(game.buttons) do
        local button_draw = draw_vars.buttons[idx]
        local h, w = button_draw.h, button_draw.w
        local x = love.graphics.getWidth() * button_draw.x - (w * love.graphics.getWidth()) / 2
        local y = love.graphics.getHeight() * button_draw.y - (h * love.graphics.getHeight()) / 2
        local button_color, text = button_draw.color, button_draw.text
        if not button.draw then
            goto continue
        end
        if button.disabled then
            button_color = { 0.5, 0.5, 0.5 }
        elseif button.pressed then
            button_color = { 1, 0, 0 }
        elseif button.hovered then
            button_color = { 1, 1, 0 }
        end

        love.graphics.setColor(button_color) -- Use appropriate color based on state
        love.graphics.rectangle("fill", x, y, w * love.graphics.getWidth(), h * love.graphics.getHeight())
        love.graphics.setColor(0, 0, 0)      -- black for text
        love.graphics.printf(text, x, y + (h * love.graphics.getHeight() - 20) / 2,
            w * love.graphics.getWidth(), "center")
        ::continue::
    end
end

local function draw_items()
    local MaxItems, BorderColor = Items.constants.MAX_ITEMS, Items.constants.ITEM_BORDER_COLOR

    local function find_item_by_slot(items, slot)
        for _, item in ipairs(items) do
            if item.slot == slot then
                return item
            end
        end
        -- no item by slot found, find first item witout slot & assign slot
        for _, item in ipairs(items) do
            if not item.slot then
                item.slot = slot
                return item
            end
        end
        return nil -- no item found
    end
    
    local function draw_item_bounds_generic(x, y, items)
        -- draw a grid around the item box for user to see where items go
        local bounds = Items.get_item_bounds(x, y)
        for i = 1, MaxItems do
            local bounds = bounds[i]
            local item_x, item_y = bounds.x, bounds.y
            local ItemWidth, ItemHeight = bounds.width, bounds.height
            local item = find_item_by_slot(items, i)
            -- Draw the rectangle for the item box
            love.graphics.setColor(BorderColor[1], BorderColor[2], BorderColor[3]) -- Use the constants defined in items.lua
            love.graphics.rectangle("line", item_x, item_y, ItemWidth, ItemHeight)
            if item then
                if item.hovered then
                    love.graphics.setColor(0.7, 0.7, 0.7) -- light gray for hovered item
                elseif item.pressed then
                    love.graphics.setColor(0.9, 0.9, 0.9) -- dark gray for pressed item
                elseif item.released then
                    love.graphics.setColor(1, 1, 1)       -- white for normal item
                else
                    love.graphics.setColor(0.6, 0.6, 0.6) -- white for normal item
                end

                local scaling = 8 / 3 -- scale the sprite for visibility
                local sprite = item:is_enabled_fn(game) and item.sprites.enabled or item.sprites.disabled
                love.graphics.draw(sprite, item_x, item_y, 0, scaling, scaling)

                if item.hovered or item.pressed then
                    item:draw_text_box()
                end
            end
        end
    end

    -- Draw item bounds for player and enemy items
    draw_item_bounds_generic(love.graphics.getWidth() * 0.3, love.graphics.getHeight() * 0.85, game[PLAYER].items) -- Player items (bottom left)
    draw_item_bounds_generic(love.graphics.getWidth() * 0.3, love.graphics.getHeight() * 0.1, game[ENEMY].items)   -- Enemy items (top left)
end


local function handle_button_generic(mx, my, inFn, outFn)
    -- Check if the mouse is over any of the buttons and call the appropriate function
    for key, button in pairs(game.buttons) do
        local button_draw = draw_vars.buttons[key]
        local h, w = button_draw.h, button_draw.w
        local x = love.graphics.getWidth() * button_draw.x - (w * love.graphics.getWidth()) / 2
        local y = love.graphics.getHeight() * button_draw.y - (h * love.graphics.getHeight()) / 2
        if mx >= x and mx <= x + (w * love.graphics.getWidth()) and my >= y and my <= y + (h * love.graphics.getHeight()) then
            if inFn then inFn(button) end   -- Call the in function if provided
        else
            if outFn then outFn(button) end -- Call the out function if provided
        end
    end
end

local function handle_item_generic(mx, my, inFn, outFn)
    -- Check if the mouse is over any of the items and call the appropriate function
    for i, item in ipairs(game[PLAYER].items) do
        local bounds = Items.get_item_bounds(love.graphics.getWidth() * 0.3, love.graphics.getHeight() * 0.85)[item.slot or i]
        local x = bounds.x
        local y = bounds.y
        if mx >= x and mx <= x + bounds.width and my >= y and my <= y + bounds.height then
            if inFn then inFn(item) end   -- Call the in function if provided
        else
            if outFn then outFn(item) end -- Call the out function if provided
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
    handle_item_generic(mx, my,
        function(item)
            item.hovered = true
        end,
        function(item)
            item.hovered = false
            item.pressed = false -- Reset pressed state if the mouse is dragged out
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

        handle_item_generic(mx, my,
            function(item)
                item.pressed = true -- Set pressed state to true
            end
        )
    end
end

local function handle_pass_to_player_turn()
    -- Handle the player's turn after passing
    if game[PLAYER].meta.next_turn_skip then
        game[PLAYER].meta.next_turn_skip = false
    else
        game.turn = Actors.PLAYER
        game.buttons.shoot.disabled = false
        game.buttons.pass.disabled = false
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
    local target_y = (direction == Actors.PLAYER) and (love.graphics.getHeight() * 0.9) or
    (love.graphics.getHeight() * 0.1 + math.random(-50, 50))
    local tween_duration = 0.2 -- duration of the tween in seconds
    Timer.tween(tween_duration, bullet.pos, { x = target_x, y = target_y }, 'in-linear', function()
        -- Callback after tweening is done, you can add any additional logic here
        bullet.used = true -- mark the bullet as used
        game.gun.current_round = game.gun.current_round + 1

        if bullet.type == BulletTypes.LIVE then
            if direction == Actors.PLAYER then
                game[PLAYER].health = math.max(0, game[PLAYER].health - bullet.dmg)
            elseif direction == Actors.ENEMY then
                game[ENEMY].health = math.max(0, game[ENEMY].health - bullet.dmg)
            end
        end

        local function handle_end_of_turn()
            -- if turn and direction are the same, the actor gets to shoot again
            if game.turn == direction and bullet.type == BulletTypes.BLANK then
                -- no op. but we enable the buttons again for the player to shoot again if it's their turn
                if game.turn == Actors.PLAYER then
                    handle_pass_to_player_turn()
                end
            else
                -- we know that an actor shot the other actor, so we switch Actors no matter what
                if game.turn == Actors.PLAYER and game[PLAYER].health > 0 and game[ENEMY].health > 0 then
                    game.turn = Actors.ENEMY
                    do_enemy_turn() -- handle enemy's turn logic
                else
                    handle_pass_to_player_turn()
                end
            end
        end

        if game[PLAYER].health <= 0 or game[ENEMY].health <= 0 then
            handle_game_over() -- Check for game over condition
            return
        elseif game.gun.current_round > game.gun.total_rounds then
            handle_reload(handle_end_of_turn) -- Reload the gun if all rounds are used
        else
            handle_end_of_turn()              -- Handle end of turn logic
        end
    end)
end

do_enemy_turn = function() -- Handle enemy's turn logic here
    -- For simplicity, let's say the enemy always shoots
    local current_round = game.gun.rounds[game.gun.current_round]
    print("Enemy's turn, current round type:", current_round.type)
    if (game[ENEMY].meta.next_turn_skip) then
        print("Enemy's turn skipped")
        game[ENEMY].meta.next_turn_skip = false
        game.turn = Actors.PLAYER
        game.buttons.shoot.disabled = false
        game.buttons.pass.disabled = false
    else
        handle_shooting_generic(Actors.PLAYER, current_round)
    end
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

        handle_item_generic(mx, my,
            function(item)
                item:activate(game)
                item.pressed = false -- Reset pressed state after action
            end
        )
    end
end

local function load_images()
    game.images.yinYangSpritesheet = love.graphics.newImage("assets/sprites/yinyang.png")
    game.images.yinYangSpritesheet:setFilter("nearest", "nearest")
    game.images[BulletTypes.UNKNOWN] = love.graphics.newQuad(0, 0, 32, 32, game.images.yinYangSpritesheet:getDimensions())
    game.images[BulletTypes.LIVE] = love.graphics.newQuad(32, 0, 32, 32, game.images.yinYangSpritesheet:getDimensions())
    game.images[BulletTypes.BLANK] = love.graphics.newQuad(64, 0, 32, 32, game.images.yinYangSpritesheet:getDimensions())
    game.images.heart_filled = love.graphics.newImage("assets/sprites/heart_filled.png")
    game.images.heart_empty = love.graphics.newImage("assets/sprites/heart_empty.png")
    load_background()
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
    -- draw_debug_grid()
    -- draw background, sliightly grey
    love.graphics.clear(0.1, 0.1, 0.1) -- Clear the screen with a dark color
    draw_background()
    draw_gun_rounds()

    draw_buttons()
    draw_turn_indicator()
    draw_health_bar(0.05, 0.9, game[PLAYER].health, game[PLAYER].max_health)
    draw_health_bar(0.05, 0.1, game[ENEMY].health, game[ENEMY].max_health)
    draw_items()
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
