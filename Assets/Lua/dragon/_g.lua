--[[
    全局表包装
]]

local M = {
    global = {},
    enabled = false
}

local mt = {}
setmetatable(_G, mt)

mt.__index = function(t, k)
    return M.global[k]
end

mt.__newindex = function(t, k, v)
    local enabled = type(M.enabled) == "function" and M.enabled() or M.enabled
    if enabled then
        M.global[k] = v
    else
        error("global variant can not be define, please check your code!")
    end
end

return M


