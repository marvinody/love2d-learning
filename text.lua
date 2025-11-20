local function write_text_box(text, x, y, width, height, font, color)
    -- add a background box with a small gradient border
    love.graphics.setColor(0, 0, 0, 0.8)                         -- Semi-transparent black
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1, 0.8)                         -- Semi-transparent white
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.setColor(color.r, color.g, color.b, 1)         -- Set text color
    love.graphics.setFont(font)
    love.graphics.printf(text, x + 5, y + 5, width - 10, "left") -- Draw text with padding
    love.graphics.setColor(1, 1, 1, 1)                           -- Reset color to white
end

local TEXT_SPEED = 200 -- Characters per second

local function make_text_dialogue_setup(text, template, done)
    return {
        text = text,
        font = template.font or love.graphics.getFont(),
        timers = { elapsed = 0, chevron = 0 },
        color = template.color or { r = 1, g = 1, b = 1 },
        typing_speed = template.typing_speed or TEXT_SPEED,
        visible_characters = 0,
        chevron_y_offset = 0,
        chevron_direction = 1,
        x = template.x * love.graphics.getWidth(),
        y = template.y * love.graphics.getHeight(), -- Position of the text box
        width = template.width * love.graphics.getWidth(), -- Width of the text box
        height = template.height * love.graphics.getHeight(), -- Height of the text box

        update = function(self, dt)
            -- Update the timer and calculate the number of visible characters
            self.timers.elapsed = self.timers.elapsed + dt
            if self.visible_characters < #self.text then
                -- Calculate the number of characters to display based on elapsed time and typing speed
                self.visible_characters = math.min(#self.text, math.floor(self.timers.elapsed * self.typing_speed))
            end

            -- Update the chevron's vertical position
            self.timers.chevron = self.timers.chevron + dt
            self.chevron_y_offset = math.sin(self.timers.chevron * 4) * 5
        end,

        draw = function(self)
            -- Display only the visible portion of the text
            local visible_text = self.text:sub(1, self.visible_characters)
            local x = self.x
            local y = self.y
            local width = self.width
            local height = self.height

            write_text_box(visible_text, x, y, width, height, self.font, self.color)

            -- Draw the chevron in the bottom-right corner of the box
            if self.visible_characters == #self.text then
                local chevron_x = x + width - 15
                local chevron_y = y + height - 15 + self.chevron_y_offset

                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.polygon("fill", chevron_x, chevron_y, chevron_x + 10, chevron_y, chevron_x + 5, chevron_y + 10)
            end
        end,

        in_bounds = function(self, mouse_x, mouse_y)
            -- Check if the mouse coordinates are within the bounds of the text box
            return mouse_x >= self.x and mouse_x <= (self.x + self.width) and
                   mouse_y >= self.y and mouse_y <= (self.y + self.height)
        end,
        mouse_released = function(self, x, y, button)
            if button ~= 1 then return end -- Only handle left mouse button

            if self:in_bounds(x, y) then
                -- If the text is fully visible, trigger the next action (e.g., close dialogue)
                if self.visible_characters == #self.text then
                    done()
                    return true -- Indicate that the dialogue can be closed or advanced
                else
                    -- Otherwise, skip to the end of the text
                    self.visible_characters = #self.text
                end
            end
            
        end,
    }
end

return {
    write_text_box = write_text_box,
    make_text_dialogue_setup = make_text_dialogue_setup,
}