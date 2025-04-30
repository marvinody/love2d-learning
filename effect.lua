-- effect.lua

local Effect = {}
Effect.__index = Effect

--- Creates a new effect instance.
-- @param options A table containing initial values for the effect's properties.
--   - timing (string): The type of effect (e.g., 'damage', 'heal', 'buff'). Defaults to 'generic'.
--   - duration (number): How long the effect lasts in seconds. 0 could mean instant or infinite depending on usage. Defaults to 0.
--   - magnitude (number): The strength or amount of the effect. Defaults to 0.
--   - target (any): The entity the effect is applied to. Defaults to nil.
--   - onApply (function): Optional function called when the effect is applied. `function(effect, target)`
--   - onUpdate (function): Optional function called periodically. `function(effect, dt)`
--   - onRemove (function): Optional function called when the effect ends or is removed. `function(effect, target)`
-- @return A new effect object (table).
function Effect:new(options)
    options = options or {} -- Ensure options table exists, even if empty

    local instance = {
        timing = options.timing or 'generic',
        target = options.target or nil,
        isActive = true, -- Whether the effect is currently active
        onApply = options.onApply,
        onUpdate = options.onUpdate,
        onRemove = options.onRemove,
    }

    -- Set the metatable to allow calling methods defined on Effect table (like Effect:update if added later)
    setmetatable(instance, self)

    return instance
end

function Effect:apply(state)
    if not self.isActive then return end
    if self.onApply then
        self:onApply(state)
    end
    -- Additional logic for applying the effect can be added here
end

function Effect:remove()
    if not self.isActive then return end
    self.isActive = false
    if self.onRemove then
        self.onRemove(self, self.target)
    end
    -- Clean up references or notify systems if necessary
end


function Effect.filter_type(effects, type)
    local filtered = {}
    for _, effect in ipairs(effects) do
        if effect.timing == type then
            table.insert(filtered, effect)
        end
    end
    return filtered
end


return Effect