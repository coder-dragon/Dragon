--[[
    事件模块
]]--

local traceback = debug.traceback
local dragon = require "dragon"

local log = dragon.logging.get("event")

local all = {} -- <event_name, handlers>
local onces = {} -- <event_name, <handlers, once>>

local function get_handlers(t, event_name)
    local ret = t[event_name]
    if not ret then
        ret = {}
        t[event_name] = ret
    end
    return ret
end

--- 订阅某个事件
--- @param event_name string 事件名
--- @param handler function 事件处理函数
--- @param once boolean 是否仅处理一次事件
local function on(event_name, handler, once)
    assert(event_name and type(event_name) == "string")
    once = once and true or false
    local handlers = get_handlers(onces, event_name)
    if handlers[handler] ~= nil then
        handlers[handler] = once -- 已订阅，更新配置
        return
    end

    handlers[handler] = once
    handlers = get_handlers(all, event_name)
    table.insert(handlers, handler)
end

--- 取消订阅某个事件
--- @param event_name string 事件名
--- @param handler function 事件处理函数
local function off(event_name, handler)
    assert(event_name and type(event_name) == "string")
    local handlers = get_handlers(onces, event_name)
    handlers[handler] = nil

    handlers = get_handlers(all, event_name)
    for i,v in ipairs(handlers) do
        if v == handler then
            table.remove(handlers, i)
            return
        end
    end
end

local handler_buffer = {}

--- 抛出某个事件
--- @param event_name string 事件名
--- @param args any 事件参数集合
local function emit(event_name, args)
    assert(event_name and type(event_name) == "string")
    local handlers = all[event_name]
    if not handlers then
        return
    end

    local onces = onces[event_name] or dragon.empty
    local total = #handlers -- 在事件回调过程中可能handlers会被修改
    for i, handler in ipairs(handlers) do
        handler_buffer[i] = handler
    end
    local pos = 1
    for i=1, total do
        local handler = handler_buffer[i]
        local ok, result = pcall(handler, args)
        if not ok then
            log.error(string.format("事件处理失败：%s %s %s %s", event_name, handler, result, traceback()))
        end
        local once = onces[handler]
        if onces[handler] == true then
            onces[handler] = nil
            table.remove(handlers, pos)
        else
            pos = pos + 1
        end
    end
end

--- event元方法，创建对应事件名的事件对象
--- @param self table 事件对象
--- @param name string 事件名
local function make(self, name)
    local ret = {
        on = function(handler, once) on(name, handler, once) end,
        off = function(handler) off(name, handler) end
    }
    setmetatable(ret, {
        __call = function(self, args) emit(name, args) end
    })
    return ret
end

return setmetatable({
    on = on,
    off = off,
    emit = emit
},{
    __call = make
})