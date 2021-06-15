local dragon = require "dragon"
local log = dragon.logging.get("element")

local UE = CS.UnityEnine
local GameObject = UE.GameObject
local Vector3 = UE.Vector3

local Dragon = CS.Dragon
local AssetLoaderPool = Dragon.Loaders.AssetLoaderPool
local LuaInjectionType = typeof(Dragon.LuaExtensions.LuaInjection)

local M = blaze.class()
M.overridemetatable = function(t, mt)
    mt.__gc = function(self)
        self:release(true)
    end
    setmetatable(t, mt)
end

M.binders = {}
M.app = dragon

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

-- 释放这个元素，保证不再使用
function M:release(gc)
    if self.released then
        return
    end
    self.released = true
end

-- 同步 加载界面所需要的游戏对象/配置等资源
function M:load()
    if self.loading or self.loaded then
        return
    end
    self.loading = true
    local ok = xpcall(function() self:on_load() end,function(err)
        log.error(string.format("加载element失败 res=%s err=%s %s", self.res, err, debug.traceback()))
    end)
    self.loading = true
    --TODO: 加载   
end

-- 异步 加载界面所需要的游戏对象/配置等资源
function M:start_load()
    if self.loading or self.loaded then
        return
    end
    self.app.couroutine.start(self.load, self)
end

function M:on_load()
    if self.res and not self.gameobject then
        local ok, result = self.app.res.load(self.res)
        if ok then
            local gameobject = result:GetFromPool()
        else
            
        end
    end
end

function M:set_gameobject(gameobject, inject)
    
end




