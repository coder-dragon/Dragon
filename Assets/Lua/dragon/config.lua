--[[
    配置模块
]]--

local dragon = require "dragon"
local log = dragon.logging.get("config")

local M = {}

local function search_config(t, name)
    local path = "config." .. name
    if dragon.package_exists(path) then
        local ok, result = xpcall(function() return require(path) end, function(e)
            log.error(string.format("load config module %s error:%s\n%s", name, e, debug.traceback()))
        end)
        if ok then
            rawset(t, name, result)
            return result
        end
    end
end

function M.load(path, mode)
    mode = mode or "bt"
    local runtime = dragon.appconfig.runtime
    local chunk
    local ok, result = pcall(function()
        if runtime then
            path = string.format("configs/%s", path)
            chunk = FS:ReadAllBytes(path)
        else
            chunk = CS.dragon.EditorOnly.ConfigLoader.ReadAllBytes(path)
        end
        if not chunk then
            return nil
        end
        return load(chunk, path, mode)()
    end)
    if ok then
        return result
    else
        log.error(string.format("加载配置失败：%s %s", path, result))
        return {}
    end
end

function M.load_bytes(path)
    local runtime = dragon.appconfig.runtime
    local bytes
    local ok, result = pcall(function()
        if runtime then
            path = string.format("configs/%s", path)
            return FS:ReadAllBytes(path)
        else
            return CS.dragon.EditorOnly.ConfigLoader.ReadAllBytes(path)
        end
    end)
    if ok then
        return result
    else
        log.error(string.format("加载配置失败：%s %s", path, result))
        return nil
    end
end

return setmetatable(M, {
    __index = search_config
})