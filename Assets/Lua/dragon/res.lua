--[[
    资源模块
]]
local dragon = require "dragon"
local NS = CS.Dragon.Loaders
local AssetLoaderPool = NS.AssetLoaderPool
local AssetBundleLoaderType = typeof(NS.AssetBundleLoader)
local AssetLoaderType = typeof(NS.AssetLoader)
local Sync = NS.AssetLoadMode.Sync
local Async = NS.AssetLoadMode.Async

local res = {}
local loader_map = {}

local function init(app)
    res.app = app
end

-- 加载指定路径的资源
-- uri 资源路径
-- options.sync 同步加载
-- options.loader_type 加载器类型
local function load(uri, options)
    assert(uri)
    options = options or dragon.empty
    local loader_type = options.loader_type or AssetLoaderType
    local loader_mode = options.sync and Sync or Async
    local loader = AssetLoaderPool.Get(loader_type, uri)
    loader.Mode = loader_mode
    loader:Start()
    loader_map[uri] = loader
    while not loader.IsDone do
        coroutine.yield()
    end
    if loader.IsOk then
        return true, loader.Result, loader
    else
        return false, loader.Error, loader
    end
end

-- 加载指定路径的资源
-- uri 资源路径
local function unload(uri)
    assert(uri)
    local loader = loader_map[uri]
    if loader then
        AssetLoaderPool.Put(loader)
    end
end

return {
    load = load,
    unload = unload
}