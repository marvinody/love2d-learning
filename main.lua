if arg[2] == "debug" then
    require("lldebugger").start()
end

states = {}
states.menu = require ('menu')
states.game = require ('game')

state = states.menu


function love.load ()
	love.window.setMode(960, 540, {
        fullscreen = false,  -- Set to true for fullscreen
        resizable = false,   -- Disable resizing to maintain aspect ratio
        vsync = true,        -- Enable vertical sync
        minwidth = 960,      -- Minimum width (optional)
        minheight = 540      -- Minimum height (optional)
    })
	state.load ()
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