-- https://stackoverflow.com/questions/72424838
local function clamp(component)
  return math.min(math.max(component, 0), 255)
end

local function adjustLightness(col, amt)
  local r = clamp((col[1] * 255) + (amt * 255))
  local g = clamp((col[2] * 255) + (amt * 255))
  local b = clamp((col[3] * 255) + (amt * 255))
  return { r / 255, g / 255, b / 255 }
end

-- Export the function
return {
  adjustLightness = adjustLightness
}
