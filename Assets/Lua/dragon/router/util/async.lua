local M = {}

function M.run_queue(queue, fn, cb)
    if #queue == 0 then
        cb()
        return
    end
    
    local step
    step = function(index)
        if index > #queue then
            cb()
        else
            if queue[index] then
                fn(queue[index], function() step(index + 1) end)
            else
                step(index + 1)
            end
        end
    end
    step(1)
end

return M