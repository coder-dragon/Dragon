--[[
    移除对应的路由表记录
]]

local clean_path = require("dragon.router.util.path").clean_path

local function normalize_path(path, parent)
    if path:sub(1, 1) == "/" then
        return path
    end

    if parent == nil then
        return path
    end

    return clean_path(string.format("%s/%s", parent.path, path))
end

--- 递归移除路由记录
--- @param path_list table 路由记录列表
--- @param path_map table 路由记录kv表 {path, record}
--- @param name_map table 路由记录kv表 {name, record}
--- @param route table 路由节点配置表
--- @param parent table 路由记录父节点
--- @param match_as string 路由别名
local function remove_route_record(path_list, path_map, name_map, route, parent, match_as)
    local path = route.path
    local name = route.name
    assert(path, "'path' is required in a route configuration.")

    local normalized_path = normalize_path(path, parent)
    local record = {
        path = normalized_path
    }

    if route.children then
        for _, child in ipairs(route.children) do
            local child_match_as
            if match_as then
                child_match_as = clean_path(string.format("%s/%s", match_as, child.path))
            end
            remove_route_record(path_list, path_map, name_map, child, record, child_match_as)
        end
    end

    if route.alias then
        local aliases = type(route.alias) == "table" and route.alias or {route.alias}
        for _, alias in ipairs(aliases) do
            local alias_route = {
                path = alias,
                children = route.children
            }
            remove_route_record(path_list, path_map, name_map, alias_route, parent, record.path or "/")
        end
    end

    if path_map[record.path] then
        for index, p in ipairs(path_list) do
            if p == record.path then
                table.remove(path_list, index)
                break
            end
        end

        path_map[record.path] = nil
    end

    if name then
        if name_map[name] then
            name_map[name] = record
        end
    end
end

--- 移除新的路由表节点配置
--- @param routes table 路由表节点配置
--- @param old_path_list table 路由记录列表
--- @param old_path_map table 路由记录kv表 {path, record}
--- @param old_name_map table 路由记录kv表{name, record}
return function(routes, old_path_list, old_path_map, old_name_map)
    local path_list = old_path_list or {}
    local path_map = old_path_map or {}
    local name_map = old_name_map or {}

    for _, route in ipairs(routes) do
        remove_route_record(path_list, path_map, name_map, route)
    end
end