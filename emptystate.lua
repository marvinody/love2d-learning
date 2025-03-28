local menu = {}

menu.load = function()
    -- Load any resources needed for the menu here
end

menu.update = function(dt)
    -- Update the menu state here, if needed
end

menu.draw = function()

end

menu.mousepressed = function(x, y, button, istouch, presses)
    -- Handle mouse press events here
end

menu.mousemoved = function(x, y, dx, dy, istouch)
    -- Handle mouse movement events here
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