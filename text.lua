local function write_text_box(text, x, y, width, height, font, color)
    -- add a background box with a small gradient border
    love.graphics.setColor(0, 0, 0, 0.8) -- Semi-transparent black
    love.graphics.rectangle("fill", x, y, width, height)
    love.graphics.setColor(1, 1, 1, 0.8) -- Semi-transparent white
    love.graphics.rectangle("line", x, y, width, height)
    love.graphics.setColor(color.r, color.g, color.b, 1) -- Set text color
    love.graphics.setFont(font)
    love.graphics.printf(text, x + 5, y + 5, width - 10, "left") -- Draw text with padding
    love.graphics.setColor(1, 1, 1, 1) -- Reset color to white
end

return {
    write_text_box = write_text_box,
}