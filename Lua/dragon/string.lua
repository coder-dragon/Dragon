--[[
    提供额外的字符串操作功能
]]

-- 将字符串分割为数组
local function split(self, sep)
    local sep, fields = sep or ",", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) table.insert(fields, c) end)
    return fields
end

return {
    split = split,
}