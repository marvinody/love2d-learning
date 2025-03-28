local game = {}

game.load = function()
    -- Load any resources needed for the game here
end

game.update = function(dt)
    -- Update the game state here, if needed
end

game.draw = function()

end

game.mousepressed = function(x, y, button, istouch, presses)
    -- Handle mouse press events here
end

game.mousemoved = function(x, y, dx, dy, istouch)
    -- Handle mouse movement events here
end

game.mousereleased = function(x, y, button, istouch, presses)
    -- Handle mouse release events here
end

game.keypressed = function(key, scancode, isrepeat)
    -- Handle key press events here
end

game.resize = function()
    -- Handle resizing of the game here
end

return game