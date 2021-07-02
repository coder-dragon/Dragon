local blaze = require "blaze"
local UIElement = require "blaze.ui.element"
local EmptyTweener = require "blaze.ui.tween.EmptyTweener"
local resolve_components = require "blaze.router.util.resolve-components"
local resolve_async_components = resolve_components.resolve_async_components
local yield = coroutine.yield

local UnityNS = CS.UnityEngine
local GameObject = UnityNS.GameObject
local CanvasType = typeof(UnityNS.UI.Canvas)

local log = blaze.logging.get("ui")
local weak_mt = { __mode = "k" }

local M = blaze.class(UIElement)

function M:ctor()
    self.tweener = EmptyTweener
    blaze.event.on("blaze.unload", function() self:release() end, true)
end

-- 当需要加载界面所需要的游戏对象/配置等资源时调用此方法
function M:on_load()
    UIElement.on_load(self)
    local gameobject = self.gameobject
    if gameobject then
        gameobject.transform:SetParent(nil, false)
        GameObject.DontDestroyOnLoad(gameobject)
    end
end

-- 当界面所使用的摄像机变更时调用此方法
function M:on_set_camera()
    if not self.gameobject then
        return
    end

    local canvas = self.gameobject:GetComponent(CanvasType)
    if canvas then
        canvas.worldCamera = self.camera
    else
        log.warn(self.gameobject.name .. " canvas is null")
    end
end

-- 当界面的层级变更时调用此方法
function M:on_set_layer()
    if not self.gameobject then
        return
    end
    local uilayer = self.gameobject:GetOrAddComponent(typeof(CS.Blaze.UI.UILayer))
    uilayer.Order = self.layer
end

-- 当界面的gameobject变更时调用此方法
function M:on_set_gameobject()
    if not self.gameobject then
        return
    end
    local depth = self._router_view and self._router_view:get_depth()
    if depth == 1 then
        -- 只有顶层路由的activity才需要用UILayer控制
        local uilayer = self.gameobject:GetOrAddComponent(typeof(CS.Blaze.UI.UILayer))
        uilayer.Order = self.layer
    end
end

-- ========== 路由事件处理 ==========

function M:before_route_leave(to, from, next)
    next()
end

function M:before_route_update(to, from, next)
    next()
end

function M.before_route_enter(to, from, next)
    next()
end

local function play_enter_tween(self, from, next)
    if not from then
        log.error("'from' should not be nil:" .. debug.traceback())
        next()
        return
    end
    self.tweener:play("Enter", next)
end

local function are_components_same(a, b)
    if a == b then
        return true
    end
    if not a or not b then
        return false
    end
    if a == b.__class or a.__class == b then
        -- 一个是class一个是instance
        return true
    end
    return false
end

local function play_leave_tween(self, to, from, next)
    if not to.matched[1] then
        self.tweener:play("Exit", next)
        return
    end

    local fn = resolve_async_components(to.matched)
    fn(to, from, function()
        local depth = self._router_view:get_depth()
        local from_matched = from.matched[depth]
        local to_matched = to.matched[depth]
        if from_matched and to_matched then
            for name, def in pairs(from_matched.components) do
                if are_components_same(self, def) then
                    -- 找到路由跳转目标同一层的视图，若相同就不需要播放离开的动画了
                    if are_components_same(def, to_matched.components[name]) then
                        next()
                    else
                        self.tweener:play("Exit", next)
                    end
                    return
                end
            end
        end
        self.tweener:play("Exit", next)
    end)
end

function M:after_route_leave(to, from)
    self:on_route_tween("Exit", to, from, blaze.noop)
    while not self.released and self.tweener.playing do
        yield()
    end
end

function M:after_route_enter(to, from)
    self:show()
    while self.loading do
        yield()
    end
    if not self.loaded then
        self:load()
    end
    if self.loaded then
        self:on_route_tween("Enter", to, from, blaze.noop)
    end
end

function M:on_route_tween(name, to, from, next)
    if not self.visible then
        next()
        return
    end

    if name == "Enter" then
        play_enter_tween(self, from, next)
    elseif name == "Exit" then
        play_leave_tween(self, to, from, next)
    elseif next then
        next()
    end
end

-- =========== 缓动事件处理 ===========

function M:on_tween_enter(name)
end

function M:on_tween_leave(name)
end

return M