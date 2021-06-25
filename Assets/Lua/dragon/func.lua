--[[
    为lua函数式编程提供支持
]]

local M = {}

-- 柯里化函数调用
-- fn(a, b) 操作方法
-- 如果调用()则返回结果并则清除缓存
function M.curry(fn)
    local cache = {}
    local result, ret
    ret = function(arg)
        if arg == nil then
            if #cache == 0 then
                cache = {}
                return result
            end
            for i = 1, #cache do
                if cache[i+1] then
                    result = fn(result or cache[i], cache[i+1])
                else
                    if result then
                        cache = {}
                        return result
                    else
                        result = cache[i]
                        cache = {}
                        return result
                    end
                end
            end
            cache = {}
            return result
        else
            table.insert(cache, arg)
            return ret
        end
    end
    return ret
end