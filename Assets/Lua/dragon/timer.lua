--[[
    时间计数器
]]
local Time = CS.UnityEngine.Time
local dragon = require "dragon" 

local timer = 
{
    __typename  = "timer",
    count       = 1,
    duration    = 1,
    loop        = 1,
    func        = nil,
    running     = false,
}

timer.__index = timer

-- func     方法回调
-- duration 等待时间
-- loop     循环次数 -1为无限次
-- scale    false 采用deltaTime计时，true 采用 unscaledDeltaTime计时
function timer.new(func, duration, loop, scale)
    local self = setmetatable({}, timer)
    scale = scale or false and true
    self:reset(func, duration, loop, scale)
    return self
end

function timer:reset(func, duration, loop, scale)
    self.duration   = duration
    self.loop       = loop
    self.func       = func
    self.scale      = false
    self.running	= false
	self.count		= Time.frameCount + 1
    self.time       = duration
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

    local delta = self.scale and Time.deltaTime or Time.unscaledDeltaTime
    self.time = self.time - delta
    if self.time < 0 and Time.frameCount > self.count then
        self.func()

        if self.loop > 0 then
            self.loop = self.loop - 1
            self.time = self.time + self.duration
        end
        
        if self.loop == 0 then
            self:stop()
        elseif self.loop < 0 then
            self.count = Time.frameCount + self.duration
        end
    end
end

local timers = {}
setmetatable(timers, {__mode = "kv"})

-- 获取一个帧数计数器对象
-- return timer
local function get(func, duration, loop, scale)
    assert(func)
    assert(duration and type(duration) == "number" and duration > 0)
    local timer = timer.new(func, duration, loop, scale)
    timers[func] = timer
    return timer
end

-- 启动一个帧数计数器
-- return timer
local function start(func, duration, loop, scale)
    assert(func)
    assert(duration and type(duration) == "number" and duration > 0)
    local timer = timer.new(func, duration, loop, scale)
    timers[func] = timer
    timer:start()
    return timer
end

-- 停止一个帧数计数器
local function stop(timer)
    if type(timer) == "table" and timer.__typename == "timer" then
        timer:stop()
    else
        error("it's not a timer")
    end
end

return
{
    get     = get,
    start   = start,
    stop    = stop
}