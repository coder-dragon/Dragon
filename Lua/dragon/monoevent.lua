--[[
    提供MonoBehaviour常用的事件回调监听，
    支持非游戏对象的监听绑定，
    游戏对象跟随对象生命周期，
    非游戏对象需要自己移除监听。
]]
local dragon = require "dragon"
local NS = CS.Dragon.MonoEventListeners

local function app() return NS.App end
local function lifecycle() return NS.Lifecycle end

local watchers = 
{
    --App生命周期
    OnApplicationFocus = app,
    OnApplicationPause = app,
    OnApplicationQuit = app,

    -- GameObject生命周期
    Start = lifecycle,
    Update = lifecycle,
    FixedUpdate = lifecycle,
    LateUpdate = lifecycle,
    OnEnable = lifecycle,
    OnDisable = lifecycle,
    OnDestroy = lifecycle,
}

local function get_watchers_class(msg_name)
    local func = watchers[msg_name]
    assert(func, string.format("找不到消息定义：%s", msg_name))
    return func
end

-- 注册事件
local function on(obj, name, func)
    obj = obj or dragon.global.root.gameObject
    assert(type(obj) == "userdata", string.format("错误的监听对象:%s", obj))
    assert(func and type(func) == "function")
    local watcher_class = get_watchers_class(name)
    local watcher = watcher_class.Get(obj)
    watcher[name.."Event"](watcher, "+", func)
end

-- 移除事件
local function off(obj, name, func)
    obj = obj or dragon.global.root.gameObject
    assert(type(obj) == "userdata", string.format("错误的监听对象:%s", obj))
    assert(func and type(func) == "function")
    local watcher_class = get_watchers_class(name)
    local watcher = watcher_class.Get(obj)
    watcher[name.."Event"](watcher, "-", func)
end

return
{
    on = on,
    off = off
}