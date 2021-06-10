--[[
    帧计数器
]]
local Time = CS.UnityEngine.Time
local dragon = require "dragon" 

local M = {}
local timer = 
{
    count       = 1,
    duration    = 1,
    loop        = 1,
    func        = nil,
    running     = false,
}

local mt = {}

mt.__index = timer


-- func     方法回调
-- count    等待帧数
-- loop     循环次数
function timer.new(func, count, loop)
    local timer = {}
    setmetatable(timer, mt)
    timer.count = Time.frameCount + count
    timer.duration = count
    timer.loop = loop
    timer.func = func
    return timer
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
    if Time.frameCount >= count then
        func()

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