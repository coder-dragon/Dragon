--[[
    提供MonoBehaviour常用的事件回调监听
]]

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

local function on(obj, name, func)
    assert(type(obj) == "userdata", string.format("错误的监听对象:%s", obj))
    assert(func and type(func) == "function")
    local watcher_class = get_watchers_class(name)
    local watcher = watcher_class.Get(obj)
    watcher[name.."Event"](watcher, "+", func)
end

local function off(obj, name, func)
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