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

-- 处理匹配路由的组件，并把组件的返回结果用promise包装调用
local function resolve_async_compnents(matched)
    return function(to, from, next)
        local has_async = false
        local pending = 0
        local err = nil
        
        local defers
        flat_map_components(matched, function(def, _, match, key)
            def = match.dynamics[k] or def
            if type(def) == "function" then
                def = promise.new(function(resolve, reject)
                    local ok, resule = pcall(function() return def(match, key) end)
                    if ok then
                        resolve(resule)
                    else
                        reject(result)    
                    end
                end)
            end

            if is_promise(def) then
                defers = defers or {}
                pending = pending + 1
                
                local resolve = function(resolved_def)
                    if resolved_def == nil then
                        def.value = nil
                    elseif type(resolved_def) == "function" then
                        def.value = resolved_def
                    else
                        def.value = resolved_def.new
                    end
                    match.components[key] = resolved_def
                    pending = pending - 1
                    if pending <= 0 then
                        next()
                    end
                end
                
                local reject = function(reason)
                    local msg = string.format("failed ro resolve async component %s: %s",key, reason)
                    if not err then
                        err = msg
                        log.warn(msg)
                        local ok, err2 = pcall(next, err)
                        if not ok then
                            log.error(string.format("fatal on next: %s", err2))
                            return
                        end
                    end
                end
                table.insert(defers, {def, resolve, reject})
            end
        end)

        if pending == 0 then
            next()
        else
            for _, defer in ipairs(defers) do
                local def = defer[1]
                local resolve = defer[2]
                local reject = defer[3]
                local res
                local ok, result = pcall(function()
                    res = def:next(resolve, reject)
                end)
                if not ok then
                    reject(result)
                end
                -- TODO:组件实例的检查逻辑
            end
        end
    end
end

M.flatten = flatten
M.flat_map_components = flat_map_components
M.resolve_async_components = resolve_async_components

return M