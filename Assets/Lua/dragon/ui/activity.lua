local dragon = require "dragon"
local UIElement = require "dragon.ui.element"
local yield = coroutine.yield

local UnityNS = CS.UnityEngine
local GameObject = UnityNS.GameObject
local CanvasType = typeof(UnityNS.UI.Canvas)

local log = dragon.logging.get("ui")
local weak_mt = { __mode = "k" }

local M = dragon.class(UIElement)

function M:ctor()
    dragon.event.on("dragon.unload", function() self:release() end, true)
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

function M:after_route_leave(to, from)
end

function M:after_route_enter(to, from)
    self:show()
    while self.loading do
        yield()
    end
    if not self.loaded then
        self:load()
    end
end

return M