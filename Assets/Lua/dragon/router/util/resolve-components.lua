local dragon = require "dragon"
local log = dragon.logging.get("router")
local array = dragon.array
local promise = dragon.promise
local is_promise = promise.is_promise

local M = {}

-- 返回一个只会调用此函数一次的闭包
local function once(fn)
    local called = false
    return function(self, ...)
        if called then
            return
        end
        called = true
        return fn(self, ...)
    end
end

-- 将一个二维table分解成一维table
local function flatten(arr)
    local ret = {}
    for _, sub_arr in ipairs(arr) do
        for _, item in ipairs(sub_arr) do
            table.insert(ret, item)
        end
    end
    return ret
end

-- 操作二维table中的所有组件，并把结果映射到一维table中
local function flat_map_components(matched, fn)
    return flatten(array.map(matched, function(m)
        local ret = {}
        for key, def in pairs(m.components) do
            ret[#ret+1] = fn(def, m.instances[key], m, key)
        end
        return ret
    end))
end

