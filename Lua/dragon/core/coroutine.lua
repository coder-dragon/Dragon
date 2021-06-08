local M = {}

--异步方法转同步
function M.async_to_sync(async_func, callback_pos)
    return function()
        local _co = coroutine.running() or error("this function must be run in coroutine")
        local rets
        local waiting = false
        local function cb_func(...)
            if waiting then
                assert(coroutine.resume( _co, ...))
            else
                rets = {...}
            end
        end
        local params = {...}
        table.insert(params, callback_pos or (#params + 1), cb_func)
        async_func(unpack(params))
        if rets == nil then
            waiting = false
            rets = {coroutine.yield()}
        end

        return unpack(rets)
    end
end