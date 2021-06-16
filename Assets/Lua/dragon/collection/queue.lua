--[[
    简易队列的实现,不可外部赋值
    queue = {
        peek,
        enqueue,
        dequeue,
        to_array,
        count
    }
]]

return function()
    local first = 1
    local last = 0
    local size = 0
    local buffer = {}

    local mt = {
        count = size,
        __index = function(t, v)
            if v == "count" then
                return size
            end
        end,
        __newindex = function(t, k, v)
            error(string.format("please do not attempt to assign a value to queue %s", debug.traceback()))
        end
    }
    
    return setmetatable({
        peek = function()
            assert(size > 0, "queue empty")
            return buffer[first]
        end,

        enqueue = function(item)
            last = last + 1
            size = size + 1
            buffer[last] = item
        end,

        dequeue = function()
            assert(size > 0, "queue empty")
            local head = buffer[first]
            first = first + 1
            size = size - 1
            return head
        end,
        
        to_array = function()
            local ret = {}
            for i=first, last do
                table.insert(ret, buffer[i])
            end
            return ret
        end
    }, mt)
end