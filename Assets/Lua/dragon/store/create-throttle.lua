--[[
    基于store mustation的数据片段重放函数
    filter:
    true 完全关闭对store的修改
    false 重放所有缓存的mutation并完全放开对store的修改
    function
          将参数作为一个filter，挤出队列中第一个mutation进行重放
          过滤器的返回值作为新一轮throttle的参数
]]
local queue = require "dragon.collections.queue"

return function(store)
    
    local throttled = false
    local buffer = queue()
    local enqueue = buffer.enqueue
    local dequeue = buffer.dequeue
    local count = function() return buffer.count end
    
    local function wrap_mutation(store, k, v)
        local mutation = store[k]
        return function(args)
            if throttled then
                enqueue(k)
                enqueue(mutation)
                enqueue(args)
            else
                mutation(args)
            end
        end
    end
    
    local mutations = store.__options.mutations
    if mutations then
        for k, v in pairs(mutations) do
            store[k] = wrap_mutation(store, k, v)
        end
    end
    
    return function(filter)
        repeat
            if filter == true then
                throttled = true
                return
            end

            if filter == false then
                throttled = false
                while count() > 0 do
                    local name = dequeue()
                    local mutation = dequeue()
                    local args = dequeue()
                    mutation(args)
                end
                break
            end
            if type(filter) == "function" then
                if count() > 0 then
                    local name = dequeue()
                    local mutation = dequeue()
                    local args = dequeue()
                    filter = filter(name, mutation, args)
                end
            else
                assert(false, string.format("invalid throttle filter:%s", filter))
            end
        until count() == 0
    end
end