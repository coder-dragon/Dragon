--[[
    Unity控制台日志输出
]]--

local dragon = require "dragon"
local loglevel = require "dragon.logging.loglevel"
local Debug = CS.UnityEngine.Debug
local map = {
    [loglevel.VERBOSE] = Debug.Log,
    [loglevel.DEBUG] = Debug.Log,
    [loglevel.WARN] = Debug.LogWarning,
    [loglevel.INFO] = Debug.Log,
    [loglevel.ERROR] = Debug.LogError,
    [loglevel.TRACE] = Debug.Log,
}

local M = {}

-- 将日志记录到介质
-- module 模块名
-- level 日志等级
-- text 需要记录的文本
-- stack 堆栈信息
-- ctx 上下文对象
function M.append(module, level, text, stack, ctx)
    if type(ctx) == "table" then
        text = text .. "\n" .. blaze.dump(ctx)
        ctx = nil
    end

    if stack then
        text = text .. "\n" .. stack
    end

    if ctx then
        map[level](text, ctx)
    else
        map[level](text)
    end
end

-- 格式化日志
-- module 模块名
-- level 日志等级
-- text 需要记录的文本
function M.format(module, level, text)
    return string.format("[%s]<time=%s/>%s", module, os.date("%X"), text)
end

return M