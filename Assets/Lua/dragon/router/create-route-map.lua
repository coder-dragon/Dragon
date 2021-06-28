--[[
    创建路由表记录
]]

local dragon = require "dragon"
local clean_path = require("dragon.router.util.path").clean_path
local Regex = CS.System.Text.RegularExpressions.Regex

local log = dragon.logging.get("create-route-map")

local M = {}
local weak_mt = { __mode = "v" }

--- 拼接与父路由的路径
--- @param path string 路径
--- @param parent table 父路由
--- @return string 拼接后的路径
local function normalize_path(path, parent)
    if string.sub(path, 1, 1) == "/" then
        return path
    end
    if parent == nil then
        return path
    end
    return clean_path(string.format("%s/%s", parent.path, path))
end

--- 添加路由记录对象
--- @param path_list table 路由记录对象列表
--- @param path_map table 路由记录对象kv表 {path, record}
--- @param name_map table 路由记录对象kv表 {name, record}
--- @param route table 路由节点配置表
--- @param parent table 路由记录父节点
--- @param match_as string 路由别名
local function add_route_record(path_list, path_map, name_map, route, parent, match_as)
    local path = route.path
    local name = route.name
    assert(path, "'path' is required in a route configuration.")
    if type(route.component) == "string" then
        local s = route.component
        route.component = function()
            return require(s)
        end
    end
    
    local normalized_path = normalize_path(path, parent)
    local record = {
        path = normalized_path,
        regex = Regex(string.format("^%s$", normalized_path)),
        dynamics = route.dynamics or {},
        components = route.components or { default = route.component },
        instances = setmetatable({}, weak_mt),
        name = name,
        parent = parent,
        match_as = match_as,
        redirect = route.redirect,
        before_enter = route.before_enter,
        meta = route.meta or {},
        children = route.children
    }
    if route.props == nil then
        record.props = {}
    elseif route.components then
        record.props = route.props
    else
        record.props = { default = route.props }
    end

    if route.children then
        for _, child in ipairs(route.children) do
            local child_match_as
            if match_as then
                child_match_as = clean_path(string.format("%s/%s", match_as, child.path))
            end
            add_route_record(path_list, path_map, name_map, child, record, child_match_as)
        end
    end

    if route.alias then
        local aliaes = type(route.alias) == "table" and route.aliaes or {route.alias}
        for _, alias in ipairs(aliaes) do
            local alias_route = {
                path = alias,
                children = route.children
            }
            add_route_record(path_list, path_map, name_map, alias_route, parent, record.path or "/")
        end
    end

    if not path_map[record.path] then
        table.insert(path_list, record.path)
        path_map[record.path] = record
    end

    if name then
        if not name_mapp[name] then
            name_map[name] = record
        elseif not match_as then
            log.warn(string.format("duplicate named routes definition: name=%s path=%s", name, record.path))
        end
    end
end

--- 创建路由表记录
--- @param routes table 路由表节点配置
--- @param old_path_list table 路由节点列表
--- @param old_path_map table 路由记录对象kv表 {path, record}
--- @param old_name_map table 路由记录对象kv表{name, record}
--- @return table 已添加新路由表节点配置的节点数据结构
return function(routes, old_path_list, old_path_map, old_name_map)
    local path_list = old_path_list or {}
    local path_map = old_path_map or {}
    local name_map = old_name_map or {}

    for _, route in ipairs(routes) do
        add_route_record(path_list, path_map, name_map, route)
    end

    -- 确保通配符总是在最后
    local i = 1
    local l = #path_list
    while i < l do
        if path_list[i] == "*" then
            table.remove(path_list, i)
            table.insert(path_list, "*")
            l = l - 1
        else
            i = i + 1
        end
    end
    
    return {
        path_list = path_list,
        path_map = path_map,
        name_map = name_map
    }
end