local StateManager = {}

function StateManager.new()
    local self = {
        current_state = nil,
        states = {},
        shared_context = {},
    }

    function self:register(name, state)
        self.states[name] = state
    end

    function self:switch(name, data)
        if self.current_state and self.current_state.exit then
            self.current_state:exit()
        end

        self.current_state = self.states[name]
        
        if data then
            for k, v in pairs(data) do
                self.shared_context[k] = v
            end
        end

        if self.current_state and self.current_state.load then
            self.current_state:load(self.shared_context, self)
        end
    end

    function self:get_context(key)
        return self.shared_context[key]
    end

    function self:set_context(key, value)
        self.shared_context[key] = value
    end

    function self:clear_context()
        self.shared_context = {}
    end

    function self:update(dt)
        if self.current_state and self.current_state.update then
            self.current_state:update(dt)
        end
    end

    function self:draw()
        if self.current_state and self.current_state.draw then
            self.current_state:draw()
        end
    end

    function self:mousepressed(x, y, button, istouch, presses)
        if self.current_state and self.current_state.mousepressed then
            self.current_state:mousepressed(x, y, button, istouch, presses)
        end
    end
    
    function self:mousereleased(x, y, button, istouch, presses)
        if self.current_state and self.current_state.mousereleased then
            self.current_state:mousereleased(x, y, button, istouch, presses)
        end
    end
    
    function self:mousemoved(x, y, dx, dy, istouch)
        if self.current_state and self.current_state.mousemoved then
            self.current_state:mousemoved(x, y, dx, dy, istouch)
        end
    end
    
    function self:keypressed(key, scancode, isrepeat)
        if self.current_state and self.current_state.keypressed then
            self.current_state:keypressed(key, scancode, isrepeat)
        end
    end
    
    function self:resize(w, h)
        if self.current_state and self.current_state.resize then
            self.current_state:resize(w, h)
        end
    end
        
    return self
end

return StateManager