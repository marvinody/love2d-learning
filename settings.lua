---@type StateManager|nil
local state_manager_ref = nil

local settings = {
    -- Default settings
    volume = {
        music = 0.5, -- Music volume (0.0 to 1.0)
        effects = 0.5 -- Sound effects volume (0.0 to 1.0)
    },
    resolution = {
        fullscreen = false -- Fullscreen mode
    },
}

-- Function to load settings from a file
function settings:load(context, state_manager)
    state_manager_ref = state_manager
    if love.filesystem.getInfo("settings.json") then
        local data = love.filesystem.read("settings.json")
        local loaded_settings = love.filesystem.decode("json", data)
        if loaded_settings then
            for k, v in pairs(loaded_settings) do
                settings[k] = v
            end
            settings:apply()
        end
    end
end

-- Function to save settings to a file
function settings:save()
    local data = love.filesystem.encode("json", settings)
    love.filesystem.write("settings.json", data)
end

-- Function to apply settings (e.g., resolution, volume)
function settings:apply()
    love.window.setMode(
        love.graphics.getWidth(),
        love.graphics.getHeight(),
        { fullscreen = settings.resolution.fullscreen }
    )
    -- Apply volume settings
    -- Note: You would need to integrate this with your audio system
    -- Example: love.audio.setVolume(settings.volume.music)
end

function settings:update(dt)
    -- update later to draw settings menu
    -- probably not needed since events will handle it
end

function settings:draw()
    -- Draw settings menu
    love.graphics.setColor(1, 1, 1) -- Reset color to white
    love.graphics.print("Settings Menu", 10, 10)
    
    -- Example: Draw volume sliders or resolution options
    love.graphics.print("Music Volume: " .. settings.volume.music, 10, 30)
    love.graphics.print("Effects Volume: " .. settings.volume.effects, 10, 50)
    love.graphics.print("Fullscreen: " .. tostring(settings.resolution.fullscreen), 10, 70)
end

-- blank functions for mouse and key events

function settings:mousepressed(x, y, button, istouch, presses)

end

function settings:mousemoved(x, y, dx, dy, istouch)

end

function settings:mousereleased(x, y, button, istouch, presses)

end

function settings:keypressed(key, scancode, isrepeat)
    if key == "escape" then
        -- Exit settings menu or return to the previous state
        print("Exiting settings menu...")

        -- Here you would typically change the state back to the previous one
        if state_manager_ref then
            state_manager_ref:switch("menu")
        end
    end
end

function settings:resize(w, h)
    -- Handle window resize events if needed
    -- For example, you might want to adjust the layout of the settings menu
    print("Settings menu resized to: " .. w .. "x" .. h)
end

return settings