--[[
    游戏基本元素，管理 unity gameobject
    支持加载/释放 gameobject
    支持设置/获取 gameobject 属性
    支持基于 lua，unity帧轮询 的协同程序管理，协同基于元素生命周期
    响应store模块事件
]]
local dragon = require "dragon"
local is_nil = dragon.is_nil
local binders = require "dragon.ui.binders"
local weak_mt = {__mode = "k"}
local log = dragon.logging.get("element")

local UE = CS.UnityEngine
local GameObject = UE.GameObject
local Vector3 = UE.Vector3

local Dragon = CS.Dragon
local LuaInjectionType = typeof(Dragon.LuaExtensions.LuaInjection)

local M = dragon.class()
M.overridemetatable = function(t, mt)
    mt.__gc = function(self)
        self:release(true)
    end
    setmetatable(t, mt)
end

M.binders = {}
M.app = dragon

-- 初始化观察者element，如果有初始化函数["$"]则调用初始化函数，如果没有，则把所有的事件都调用一次
local function init_store_watchers(self)
    if self._store_watchers_inited or not self.store_watchers then
        return
    end
    for name, handlers in pairs(self.store_watchers) do
        local store = self.app.store[name]
        if store then
            local state = store.state
            local init_handler = handlers["$"]
            for event_name, handler in pairs(handlers) do
                store.watch(self, event_name)
                if not init_handler then
                    handler(self, store, state, dragon.empty, true)
                end
            end
            if init_handler then
                init_handler(self, store, state, dragon.empty, true)
            end
        else
            log.warn(string.format("store '%s' are not found %s", name, debug.traceback()))
        end
    end
    self._store_watchers_inited = true
end

function M:ctor()
    self.loading = false
    self.loaded = false
    self.released = false
    self.layer = 0
    self.scale = Vector3.one
    self.position = Vector3.zero
    self.visible = true
    self.res = nil -- "assetbundle:assetname"
    self.parent = nil
    self.unbinders = {}
end

-- 同步 加载元素所需要的游戏对象/配置等资源
function M:load()
    if self.loading or self.loaded then
        return
    end
    self.loading = true
    local ok = xpcall(function() self:on_load() end,function(err)
        log.error(string.format("load element failed res = %s err = %s %s", self.res, err, debug.traceback()))
    end)
    self.loading = true
    if not ok then
        self.loaded = false
        return
    end
    if self.should_unload then
        self:on_unload()
        return
    end
    self:on_loaded()
end

-- 异步 加载元素所需要的游戏对象/配置等资源
function M:start_load()
    if self.loading or self.loaded then
        return
    end
    self.app.couroutine.start(self.load, self)
end

-- 卸载元素所需要的游戏对象/配置等资源
function M:unload()
    if self.loading then
        -- element正在加载
        self.should_unload = true
        return
    end
    if self.loaded then
        local ok, result = pcall(self.on_unload, self)
        if not ok then
            log.error(string.format("dispose element res failed %s", result))
        else
            self.loaded = false
        end
    end
end

-- 释放这个元素，保证不再使用
function M:release(gc)
    if self.released then
        return
    end
    local ok result = pcall(self.on_release, self, gc)
    if not ok then
        log.error(string.format("release element failed %s", result))
    end
    self:unload()
    self.released = true
end

-- 当element加载时
function M:on_load()
    if self.res and not self.gameobject then
        local ok, result = self.app.res.load(self.res)
        if ok then
            local gameobject = result:GetFromPool()
            self.poolable = true
            self:set_gameobject(gameobject, true)
        else
            log.error(string.format("load element res failed %s", result))
        end
    end
end

-- 当元素加载完成时
function M:on_loaded()
    self.loaded = true
    if self.released then
        self._lazy_queue = nil
        return
    end
    if self._lazy_queue then
        for i = 1, #self._lazy_queue, 2 do
            local name = self._lazy_queue[i]
            local args = self._lazy_queue[i+1]
            self[name](self, table.unpack(args))
        end
        self._lazy_queue = nil
    end
end

-- 当element加载完毕且需要卸载时调用此方法
function M:on_unload()
    if self.gameobject and self.poolable then
        if self.gameobject:IsNull() then
            log.warn(string.format("attempt to recycle an destoryed element gameobject %s", debug.traceback()))
        else
            self.gameobject:ReturnToPool()
        end
        self.gameobject = nil
        self.transform = nil
    end
    
    if self.res then
        self.app.res.unload(self.res)
    end
    
    if self.store_watchers then
        for name, _ in pairs(self.store_watchers) do
            local store = self.app.store[name]
            if store then
                store.unwatch(self)
            else
                log.warn(string.format("store '%s' are not found %s", name, debug.traceback()))
            end
        end
        self._store_watchers_inited = false
    end
    self.store_watchers = nil
    
    for _, unbinder in ipairs(self.unbinders) do
        unbinder()
    end

    self:stop_all_coroutines()
    
    self.loading = false
    self.loaded = false
end

-- 当需要彻底释放这个元素元素且不再使用时调用此方法
-- gc 是否由gc调用的回收
function M:on_release(gc)
    
end

-- 绑定gameobject
-- gameobject 需要绑定的对象
-- inject 是否注入
function M:set_gameobject(gameobject, inject)
    if self.gameobject == gameobject then
        return
    end
    self.gameobject = gameobject
    self.transform = gameobject.transform
    
    self:on_set_gameobject()

    if self.released then
        return
    end

    if not inject then
        init_store_watchers(self)
        return
    end
    local injection = gameobject:GetComponent(LuaInjectionType)
    if not injection then
        init_store_watchers(self)
        return
    end
    if not self.on_injected then
        init_store_watchers(self)
        return
    end
    local bind = function(method, ref, ...)
        local binders = binders[method] or self.app.config.binders and self.app.config.binders[name]
        assert(binders, "can not find binder method "..method)
        local unbinder = binder(self, ref, ...)
        if unbinder then
            table.insert(self.unbinders, unbinder)
        end
    end
    self:on_injected(bind)
    init_store_watchers(self)
end

-- 调用element上的方法，如果未加载完成，则加入缓存队列在加载完成后调用
function M:lazy(name, ...)
    if self.loaded then
        self[name](self, ...)
    else
        self._lazy_queue = self._lazy_queue or {}
        table.insert(self._lazy_queue, name)
        table.insert(self._lazy_queue, table.pack(...))
    end
end

--===================gameobject操作====================--
-- 显示元素
function M:show(visible)
    self:set_visibility(visible or true)
end

-- 隐藏元素
function M:hide()
    self:set_visibility(false)
end

-- 设置元素可见性
function M:set_visibility(visible)
    if self.visible == visible then
        return
    end
    self.visible = visible
    self:lazy("on_set_visibility")
end

-- 设置元素层级
function M:set_layer(layer)
    if self.layer == layer then
        return
    end
    self.layer = layer
    self:lazy("on_set_layer")
end

function M:set_parent(parent, world_position_stays)
    if self.parent == parent then
        return
    end
    self.parent = parent
    self.world_position_stays = world_position_stays or false
    self:lazy("on_set_parent")
end

-- 设置元素的世界坐标
function M:set_world_position(position)
    self.world_position = position
    self:lazy("on_set_world_position")
end

-- 设置元素的偏移位置
function M:set_position(position)
    if self.position == position then
        return
    end
    self.position = position
    self:lazy("on_set_position")
end

-- 设置元素的缩放
function M:set_scale(scale)
    if self.scale == scale then
        return
    end
    self.scale = scale
    self:lazy("on_set_scale")
end

-- 设置元素的SiblingIndex
function M:set_sibling(index)
    if self.sibling == index then
        return
    end
    self.sibling = index
    self:lazy("on_set_sibling")
end

-- 设置元素在父节点下的索引为最后
function M:set_aslastsibling()
    self:lazy("on_set_aslastsibling")
end
--=======================================================--

--===================gameobject操作回调====================--
-- 当元素的gameobject变更时调用此方法
function M:on_set_gameobject()
    if is_nil(self.gameobject) then
        return
    end
    self.gameobject:SetActive(self.visible)
end

-- 当元素的可见性变更时调用此方法
function M:on_set_visibility()
    if is_nil(self.gameobject) then
        return
    end
    self.gameobject:SetActive(self.visible)
end

-- 当元素的层级变更时调用此方法
function M:on_set_layer()
    
end

-- 当元素的父节点变更时调用此方法
function M:on_set_parent()
    if is_nil(self.transform) then
        return
    end
    local transform = self.transform
    transform:SetParent(self.parent and self.parent.transform, self.world_position_stays)
end

-- 当元素的位置变更时调用此方法
function M:on_set_position()
    if is_nil(self.transform) then
        return
    end
    self.transform.localPosition = self.position
end

-- 当设置元素的世界坐标时调用此方法
function M:on_set_world_position()
    if is_nil(self.transform) then
        return
    end
    if not self.world_position then
        return
    end
    self.transform.position = self.world_position
    self.position = self.transform.localPosition
end

-- 当元素的缩放变更时调用此方法
function M:on_set_scale()
    if is_nil(self.transform) then
        return
    end
    self.transform.localScale = self.scale
end

-- 当元素的SiblingIndex变更时调用此方法
function M:on_set_sibling()
    if is_nil(self.transform) then
        return
    end
    self.transform:SetSiblingIndex(self.sibling)
end

-- 当设置元素在父节点下的索引为最后时调用此方法
function M:on_set_aslastsibling()
    if is_nil(self.transform) then
        return
    end
    self.transform:SetAsLastSibling()
end
--=======================================================--

--========================lua协同管理======================--

-- 启动一个lua协同,基于Unity帧轮询
-- func 协同方法
-- ... 协同方法参数
function M:start_coroutine(func, ...)
    assert(func, "invalid lua coroutine function")
    self._coroutine = self._coroutine or setmetatable({}, weak_mt)
    local co = self.app.coroutine.start(func, ...)
    if co == nil then
        return nil
    end
    self._coroutine[co] = true
    return co
end

-- 停止一个lua协同
function M:stop_coroutine(co)
    if not self._coroutine then
        return
    end
    self.app.coroutine.stop(co)
    self._coroutine[co] = nil
end

-- 停止所有此元素上开启的lua协同
function M:stop_all_coroutines()
    if not self._coroutine then
        return
    end
    for co, _ in pairs(self._coroutine) do
        self.app.coroutine.stop(co)
        self._coroutine[co] = nil
    end
end
--=======================================================--

-- 当数据仓库触发变更时调用此方法
function M:on_store_mutation(name, store, state, args)
    if not self.store.store_watchers then
        return
    end
    
    local category = self.store_watchers[store.name]
    if not category then
        return
    end
    
    local handler = category[name]
    if handler then
        handler(self, store, state, args)
    end
end

return M