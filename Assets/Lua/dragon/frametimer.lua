--[[
    帧计数器
]]
local Time = CS.UnityEngine.Time
local dragon = require "dragon" 

local timer = 
{
    __typename  = "frametimer",
    count       = 1,
    duration    = 1,
    loop        = 1,
    func        = nil,
    running     = false,
}

timer.__index = timer

-- func     方法回调
-- count    等待帧数
-- loop     循环次数
function timer.new(func, count, loop)
    local self = setmetatable({}, timer)
    self.count = Time.frameCount + count
    self.duration = count
    self.loop = loop
    self.func = func
    return self
end

function timer:start()
    self.running = true
    self._update = function()
        self:update()
    end
    dragon.monoevent.on(nil, "Update", self._update)
end

function timer:stop()
    self.running = false
    if not self._update then
        return
    end
    dragon.monoevent.off(nil, "Update", self._update)
end

function timer:update()
    if not self.running then
        return
    end
    if Time.frameCount >= self.count then
        self.func()

        if self.loop > 0 then
            self.loop = self.loop - 1
        end
        
        if self.loop == 0 then
            self:stop()
        else
            self.count = Time.frameCount + self.duration
        end
    end
end

local timers = {}
setmetatable(timers, {__mode = "kv"})

-- 获取一个帧数计数器对象
-- return timer
local function get(func, count, loop)
    assert(func)
    assert(count and type(count) == "number" and count >= 0)
    local timer = timer.new(func, count, loop)
    timers[func] = timer
    return timer
end

-- 启动一个帧数计数器
-- return timer
local function start(func, count, loop)
    assert(func)
    assert(count and type(count) == "number" and count >= 0)
    local timer = timer.new(func, count, loop)
    timers[func] = timer
    timer:start(func, count, loop)
    return timer
end

-- 停止一个帧数计数器
local function stop(timer)
    if type(timer) == "table" and timer.__typename == "frametimer" then
        timer:stop()
    else
        error("it's not a frametimer")
    end
end

return 
{
    get     = get,
    start   = start,
    stop    = stop
}