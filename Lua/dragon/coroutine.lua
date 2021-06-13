--[[
    实现等待帧,秒功能的lua协程
]]
local dragon = require "dragon"
local frametimer = dragon.frametimer
local timer = dragon.timer
local create = coroutine.create
local running = coroutine.running
local resume = coroutine.resume
local yield = coroutine.yield
local unpack = unpack or table.unpack
local error = error
local debug = debug

local coroutine = {}

local co_timers = {}
setmetatable(co_timers, {__mode = "kv"})

function coroutine.start(func, ...)
    local co = create(func)
    if running() == nil then
        local flag, msg = resume(co, ...)
        if not flag then
            msg = debug.traceback(co, msg)
			error(msg)
        end
    else
        local args = {...}
        local timer = nil

        local action = function()
            local flag, msg = resume(co, unpack(args))
            if not flag then
                timer:stop()
                msg = debug.traceback(co, msg)
                error(msg)
            end
        end
        timer = frametimer.start(action, 0, 1)
        co_timers[co] = timer
        timer:start()
    end

    return co
end

function coroutine.wait(t, co, ...)
    local args = {...}
    local co = co or running()
    local _timer = nil

    local action = function()
        local flag, msg = resume(co, unpack(args))
        if not flag then
            timer:stop()
            msg = debug.traceback(co, msg)
            error(msg)
        end
    end
    _timer = timer.start(action, t, 1)
    co_timers[co] = _timer
    _timer:start()
    return yield()
end

function coroutine.step(t, co, ...)
    local args = {...}
    local co = co or running()
    local timer = nil

    local action = function()
        local flag, msg = resume(co, unpack(args))
        if not flag then
            timer:stop()
            msg = debug.traceback(co, msg)
            error(msg)
        end
    end
    timer = frametimer.start(action, t or 1, 1)
    co_timers[co] = timer
    timer:start()
    return yield()
end

function coroutine.stop(co)
    local timer = co_timers[co]
    if timer ~= nil then
        co_timers = nil
        timer:stop()
    end
end

function coroutine.stop_all()
    for co, timer in pairs(co_timers) do
        co_timers[co] = nil
        timer:stop()
    end
end

--异步方法转同步, 只能在协程中执行
function coroutine.async_to_sync(async_func, callback_pos)
    return function(...)
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

return coroutine