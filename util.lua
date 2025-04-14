local function iany(tbl, fn)
    for idx, v in ipairs(tbl) do
        if fn(v, idx) then
            return true
        end
    end
    return false
end

local function any(tbl, fn)
    for key, v in pairs(tbl) do
        if fn(v, key) then
            return true
        end
    end
    return false
end

return {
    iany = iany,
    any = any,
}