if arg[2] == "debug" then
    require("lldebugger").start()
end

states = {}
states.menu = require ('menu')
states.game = require ('game')
states.settings = require ('settings')
states.char_select = require ('char_select')

state = states.menu

local width = 1920
local height = 1080

function love.load ()
	love.window.setMode(width, height, {
        fullscreen = false,  -- Set to true for fullscreen
        resizable = false,   -- Disable resizing to maintain aspect ratio
        vsync = true,        -- Enable vertical sync
        minwidth = width,      -- Minimum width (optional)
        minheight = height      -- Minimum height (optional)
    })
    state = states.game
	state.load ()
    states.settings.load() -- load settings if any saved
end

function love.update (dt)
	state.update (dt)
end

function love.draw ()
	state.draw ()
end

function love.mousepressed(x, y, button, istouch, presses)
	state.mousepressed (x, y, button, istouch, presses)
end

function love.mousemoved( x, y, dx, dy, istouch )
	state.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased (x, y, button, istouch, presses)
	state.mousereleased (x, y, button, istouch, presses)
end

function love.keypressed (key, scancode, isrepeat)
	state.keypressed (key, scancode, isrepeat)
end

function love.resize()
	state.resize (w, h)
end


local love_errorhandler = love.errorhandler

function love.errorhandler(msg)
    if lldebugger then
        error(msg, 2)
    else
        return love_errorhandler(msg)
    end
end