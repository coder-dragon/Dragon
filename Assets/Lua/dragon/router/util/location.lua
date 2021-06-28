--[[
    路由路径格式化对象
]]

local dragon = require "dragon"
local path = require "dragon.router.util.path"
local parse_path = path.parse_path
local resolve_path = path.resolve_path

local resolve_query = require("dragon.router.util.query").resolve_query
local fill_params = require("dragon.router.util.params").fill_params

local deep_clone = dragon.object.deep_clone

local M = {}

--- 合并路由路径和参数并格式化
--- @param raw string 路由路径或已格式化完成的kv表
--- @param current table 当前路由路径kv表
--- @param append boolean 路径后是否追加 "/"
--- @param router table 路由管理器
--- @return table 已格式化完成的路由路径kv表
function M.normalize_location(raw, current, append, router)
    assert(raw, "invalid location -> " .. tostring(raw))
    local next = type(raw) == "string" and { path = raw } or raw
    if next._normalized then
        return next
    elseif next.name then
        next = deep_clone({}, next)
        local params = next.params
        if params and type(params) == "table" then
            next.params = deep_clone({}, params)
        end
        return next
    end

    if not next.path and next.params and current then
        next = deep_clone({}, next)
        next._normalized = true
        local params = deep_clone(deep_clone({}, current.params), next.params)
        if current.name then
            next.name = current.name
            next.params = params
        elseif #current.matched ~= 0 then
            local raw_path = current.matched[#current.matched - 1].path
                next.path = fill_params(raw_path, params, string.format("path %s ", current.path))
            end
        return next
    end
    
    local parsed_path = parse_path(next.path or "")
    local base_path = (current and current.path) or "/"
    local path = parsed_path and resolve_path(parsed_path.path, base_path, append or next.append) or base_path
    local query = resolve_query(parsed_path.query, next.query)
    
    local hash = next.hash or parsed_path.hash
    if hash and string.sub(hash, 1, 1) == "#" then
        hash = string.format("#%s", hash)
    end
    
    return {
        _normalized = true,
        path = path,
        query = query,
        hash = hash
    }
end

return M