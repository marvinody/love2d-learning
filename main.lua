if arg[2] == "debug" then
    require("lldebugger").start()
end

local menu_state = require ('menu')
local game_state = require ('game')
local settings_state = require ('settings')
local char_select_state = require ('char_select')
local StateManager = require("StateManager")

local state_manager


local width = 1920
local height = 1080

function love.load()

    love.window.setMode(width, height, {
        fullscreen = false,  -- Set to true for fullscreen
        resizable = false,   -- Disable resizing to maintain aspect ratio
        vsync = true,        -- Enable vertical sync
        minwidth = width,      -- Minimum width (optional)
        minheight = height      -- Minimum height (optional)
    })
    state_manager = StateManager.new()

    state_manager:register("menu", menu_state)
    state_manager:register("char_select", char_select_state)
    state_manager:register("settings", settings_state)
    state_manager:register("game", game_state)


    -- TODO: load settings somehow
    
    state_manager:switch("menu")
end

function love.update(dt)
    state_manager:update(dt)
end

function love.draw()
    state_manager:draw()
end

function love.mousepressed(x, y, button, istouch, presses)
    state_manager:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
    state_manager:mousereleased(x, y, button, istouch, presses)
end

function love.mousemoved(x, y, dx, dy, istouch)
    state_manager:mousemoved(x, y, dx, dy, istouch)
end

function love.keypressed(key, scancode, isrepeat)
    state_manager:keypressed(key, scancode, isrepeat)
end

function love.resize(w, h)
    state_manager:resize(w, h)
end


local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end