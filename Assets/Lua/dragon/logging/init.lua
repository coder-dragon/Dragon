--[[
    日志模块
]]

local loglevel = require "dragon.logging.loglevel"
local unityconsole = require "dragon.logging.unityconsole"
local traceback = debug.traceback

local LEVEL_ALL = loglevel.ALL
local LEVEL_VERBOSE = loglevel.VERBOSE
local LEVEL_DEBUG = loglevel.DEBUG
local LEVEL_WARN = loglevel.WARN
local LEVEL_INFO = loglevel.INFO
local LEVEL_ERROR = loglevel.ERROR
local LEVEL_TRACE = loglevel.TRACE
local LEVEL_FATAL = loglevel.FATAL
local LEVEL_OFF = loglevel.OFF

local M = {}
local log_map = {}

-- 创建一个日志记录器
-- 日志模块名
local function create(name)
    ret = 
    {
        verbose = function(msg, ctx)
            if M.level <= LEVEL_VERBOSE then
                msg = M.formatter(name, LEVEL_VERBOSE, msg)
                M.appender(name, LEVEL_VERBOSE, msg, traceback(), ctx)
            end
        end,
        debug = function(msg, ctx)
            if M.level <= LEVEL_DEBUG then
                msg = M.formatter(name, LEVEL_DEBUG, msg)
                M.appender(name, LEVEL_DEBUG, msg, traceback(), ctx)
            end
        end,
        warn = function(msg, ctx)
            if M.level <= LEVEL_WARN then
                msg = M.formatter(name, LEVEL_WARN, msg)
                M.appender(name, LEVEL_WARN, msg, traceback(), ctx)
            end
        end,
        info = function(msg, ctx)
            if M.level <= LEVEL_INFO then
                msg = M.formatter(name, LEVEL_INFO, msg)
                M.appender(name, LEVEL_INFO, msg, nil, ctx)
            end
        end,
        error = function(msg, ctx)
            if M.level <= LEVEL_ERROR then
                msg = M.formatter(name, LEVEL_ERROR, msg)
                M.appender(name, LEVEL_ERROR, msg, traceback(), ctx)
            end
        end,
        trace = function(msg, ctx)
            if M.level <= LEVEL_TRACE then
                msg = M.formatter(name, LEVEL_TRACE, msg)
                M.appender(name, LEVEL_TRACE, msg, traceback(), ctx)
            end
        end,
        fatal = function(msg, ctx)
            if M.level <= LEVEL_TRACE then
                msg = M.formatter(name, LEVEL_FATAL, msg)
                M.appender(name, LEVEL_FATAL, msg, traceback(), ctx)
            end
        end
    }
    log_map[name] = ret
    return ret
end

local function get(name)
    name = name or "default"
    local ret = log_map[name] or create(name)
    return ret
end

local function put(name)
    assert(name)
    log_map[name] = nil
end

M.level = LEVEL_ALL    -- 日志等级，低于该等级的日志将不会被记录
M.appender = unityconsole.append -- 日志写入器，默认写入到Unity控制台
M.formatter = unityconsole.format -- 日志格式

M.get = get
M.put = put

M.LEVEL_ALL = LEVEL_ALL
M.LEVEL_VERBOSE = LEVEL_VERBOSE
M.LEVEL_DEBUG = LEVEL_DEBUG
M.LEVEL_WARN = LEVEL_WARN
M.LEVEL_INFO = LEVEL_INFO
M.LEVEL_ERROR = LEVEL_ERROR
M.LEVEL_TRACE = LEVEL_TRACE
M.LEVEL_OFF = LEVEL_OFF

return M

