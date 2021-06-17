--[[
    创建可订阅/广播事件的数据中心 store
    1. 事件系统
        订阅事件 watch 
        取消订阅 unwatch
        广播事件 emit
    2. 数据管理
        获取数据 getters
        数据操作 actions
        数据变化 mutations
        数据重放 throttle
]]

local dragon = require "dragon"
local promise = dragon.promise
local weak_mt = {__mode = "k"}
local log = dragon.logging.get("store")

-- 创建或者获取基于事件名进行分类的容器<receiver, bool>
-- store 模块
-- name 事件名
local function get_or_create_map(store, name)
    local map = store.__subscribers[name]
    if not map then
        map = setmetatable({}, weak_mt)
        store.__subscribers[name] = map
    end
    return map
end

-- 创建事件广播器，基于事件名对已放入容器的receiver进行广播
-- name 事件名 ["*"]广播所有事件
-- args 参数
local function wrap_emit(store)
    local subscribers = store.__subscribers
    return function(name, args)
        local map = get_or_create_map(store, name)
        local state = store.state
        
        for receiver, _ in pairs(map) do
            if not receiver.released then
                receiver:on_store_mutation(name, store, state, args)
            end
        end
        map = get_or_create_map(store, "*")
        for receiver, _ in pairs(map) do
            if not receiver.released then
                receiver:on_store_mutation(name, store, state, args)
            end
        end
    end
end

-- 订阅事件
-- ["*"] 全量订阅
local function wrap_watch(store)
    return function(receiver, name)
        assert(receiver and receiver.on_store_mutation, "invalid receiver")
        assert(not receiver.released, "released receiver")
        local map
        if name then
            map = get_or_create_map(store, "*")
            if map[receiver] then
                -- 已存在全量订阅表中
                return
            end
            map = get_or_create_map(store, name)
        else
            map = get_or_create_map(store, "*")
        end
        map[receiver] = true
    end
end

-- 取消订阅
-- receiver 订阅者
-- name 事件名 '*' or nil 取消全量订阅包括单项
local function wrap_unwatch(store)
    return function(receiver, name)
        assert(receiver and receiver.on_store_mutation, "invalid receiver")
        local map = get_or_create_map(store, "*")
        if name then
            if map[receiver] then
                error(string.format("已存在全量订阅，无法取消单项订阅 %s", name))
            end
            map = get_or_create_map(store, name)
        else
            -- 取消全量订阅，包括所有单项
            for _, v in pairs(store.__subscribers) do
                v[receiver] = nil
            end
        end
        map[receiver] = nil
    end
end

-- 绑定store获取数据的方式
local function wrap_getters(store)
    local state = store.state
    local defs = store.__options.getters
    if not defs then
        return
    end
    local getters = {}
    local mt = {__index = function(t, k)
        local getter = defs[k]
        if getter then
            return getter(state, getters)
        end
    end}
    setmetatable(state, mt)
    setmetatable(getters, mt)
    return getters
end

-- 绑定store单项数据变化方法
-- store[k](args)
local function wrap_mutation(store, k, v)
    return function(args)
        return v(store, store.state, args)
    end
end

-- 绑定store单项操作方法
-- store[k](args)
local function wrap_action(store, k, v)
    return function(args)
        return v(store, store.state, args)
    end
end

return function(options)
    assert(options.name, "store should have a name.")
    local state = type(options.state) == "function" and options.state() or options.state or {}
    local store = {
        name = options.name,
        __options = options,
        __subscribers = {}, -- <name, {receiver1 = true, recceiver2 = true}>
    }
    store.state = state
    store.emit = wrap_emit(store)
    store.watch = wrap_watch(store)
    store.unwatch = wrap_unwatch(store)
    store.getters = wrap_getters(store)
    
    for k, v in pairs(state) do
        state[k] = v
    end
    
    local mutations = options.mutations
    if mutations then
        for k, v in pairs(mutations) do
            store[k] = wrap_mutation(store, k, v)
        end
    end
    
    local actions = options.actions
    if actions then
        for k, v in pairs(actions) do
            store[k] = wrap_action(store, k, v)
        end
    end

    if options.throttleable then
        local create_throttle = require "dragon.store.create-throttle"
        store.throttle = create_throttle(store)
    end
    return store
end