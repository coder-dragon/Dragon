--[[
    简易字典的实现,不可外部赋值
    
    获取键对应的值 get(k)
    设置键值      set(k,v)
    清空容器      clear()
    返回可迭代对象 pair()
    获取键值数量   count 
]]

return function(kvs)
    assert(kvs == nil or type(kvs) == "table")
    
    local items = {}
    local total = 0
    
    if kvs then
        for k, v in pairs(kvs) do
            items[k] = v
            total = total + 1
        end
    end
    
    local mt = {
        count = total,
        __index = function(t, v)
            if v == "count" then
                return total
            end 
        end,
        __newindex = function(t, k, v)
            error(string.format("please do not attempt to assign a value to dict %s", debug.traceback()))
        end
    }
    return setmetatable({
        get = function(k) return items[k] end,
        set = function(k, v)
            assert(k)
            local origin = items[k]
            if v == nil then
                if origin == nil then
                    return
                else
                    items[k] = nil
                    total = total - 1
                end
            else
                if origin == nil then
                    total = total + 1
                end
                items[k] = v
            end 
        end,
        clear = function()
            items = {}
            total = 0
        end,
        pairs = function()
            return pairs(items)
        end
    }, mt)
end 