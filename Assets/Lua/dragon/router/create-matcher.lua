--[[
    初始化路由表配置，并返回一个 可添加、移除路由表配置，创建匹配路径的路由对象 的对象
]]

local dragon = require "dragon"
local resolve_path = require("dragon.router.util.path").resolve_path
local fill_params = require("dragon.router.util.params").fill_params
local normalize_location = require("dragon.router.util.location").normalize_location
local create_route_map = require("dragon.router.create-route-map")
local remove_route_map = require("dragon.router.remove-route-map")
local Route = require("dragon.router.route")

local log = dragon.logging.get("create-matcher")

--- 用正则匹配当前路径 匹配成功则加入路径参数
--- @param regex userdata 路径正则对象
--- @param params table
--- @return boolean 是否匹配当前路径
local function match_route(regex, path, params)
    local match = regex:Match(path)
    if not match.Success then
        return false
    end
    if not params then
        return true
    end
    for i = 0, match.Groups.Count - 1 do
        local group = match.Groups[i]
        params[group.Name] = group.Value
    end
    return true
end

--- 拼接当前路径与父节点路径
--- @param path string 当前路径
--- @param record table 当前路由表记录
--- @return string 返回拼接父路径后的路径
local function resolve_record_path(path, record)
    return resolve_path(path, record.parent and record.parent.path or "/", true)
end

--- 返回一个可以 添加、移除、创建匹配路径的路由对象 的对象
--- @param routes table 路由表配置
--- @param router table 路由管理器
--- @return table 可以 添加、移除、创建匹配路径的路由对象 的对象
return function(routes, router)
    local map = create_route_map(routes)
    local path_list = map.path_list
    local path_map = map.path_map
    local name_map = map.name_map
    local match
    local _create_route

    --- 根据重定向创建路由表 直至匹配成功则创建
    --- @param record table 路由表节点记录
    --- @param location table 路由路径格式化对象
    --- @return table 匹配成功的路由节点
    local function redirect(record, location)
        local original_redirect = record.redirect
        local redirect = type(original_redirect) == "function"
                and original_redirect(Route.new(record, location, nil, router))
                or original_redirect

        if type(redirect) == "string" then
            redirect = { path = redirect }
        end

        if not redirect or type(redirect) ~= "table" then
            return _create_route(nil, location)
        end

        local re = redirect
        local name, path = re.name, re.path
        local query, hash, params = location.query, location.hash, location.params
        query = re.query or query
        hash = re.hash or hash
        params = re.params or params

        if name then
            local target_record = name_map[name]
            assert(target_record, string.format("重定向失败：命名路由'%s'不存在", name))
            return match({
                _normalized = true,
                name = name,
                query = query,
                hash = hash,
                params = params
            }, nil, location)
        elseif path then
            local raw_path = resolve_record_path(path, record)
            local resolved_path = fill_params(raw_path, params, string.format("路由重定向：%s", raw_path))
            return match({
                _normalized = true,
                path = resolved_path,
                query = query,
                hash = hash
            }, nil, location)
        else
            return _create_route(nil, location)
        end
    end

    --- 根据别名创建路由表
    --- @param record table 当前路由记录
    --- @param location table 路由路径格式化对象
    --- @param match_as table 路由别名
    local alias = function(record, location, match_as)
        local aliased_path = fill_params(match_as, location.params, string.format("路由别名：%s", match_as))
        local aliased_match = match({
            _normalized = true,
            path = aliased_path
        })
        if aliased_match then
            local matched = aliased_match.matched
            local aliased_record = matched[#matched]
            location.params = aliased_match.params
            return _create_route(aliased_record, location)
        end
        return _create_route(nil, location)
    end

    --- 创建路由节点
    --- @param record table 路由记录
    --- @param location table 路由路径格式化对象
    --- @param redirected_from table 重定向来源节点
    _create_route = function(record, location, redirected_from)
        if record and record.redirect then
            return redirect(record, redirected_from or location)
        end
        if record and record.match_as then
            return alias(record, location, record.match_as)
        end
        return Route.new(record, location, redirected_from, router)
    end

    --- 添加路由节点
    --- @param routes table 路由节点配置
    local add_routes = function(routes)
        create_route_map(routes, path_list, path_map, name_map)
    end

    --- 移除路由节点
    --- @param routes table 路由节点配置
    local remove_routes = function(routes)
        remove_route_map(routes, path_list, path_map, name_map)
    end

    --- 创建匹配的路由节点
    --- @param raw table 路由路径或者已格式化的对象
    --- @param current_route table 当前路由节点
    --- @param redirected_from table 重定向来源节点
    match = function(raw, current_route, redirected_from)
        local location = normalize_location(raw, current_route, false, router)
        local name = location.name

        if name then
            local record = name_map[name]
            if not record then
                log.warn(string.format("Route with name '%s' does not exist", name))
                return _create_route(nil, location)
            end
            local param_names = record.regex:GetGroupNames()
            if type(location.params) ~= "table" then
                location.params = {}
            end

            if current_route and type(current_route.params == "table") then
                for key, _ in pairs(current_route.params) do
                    if not location.params[key] and array.index_of(param_names, key) > 0 then
                        location.params[key] = current_route.params[key]
                    end
                end
            end

            if record then
                location.path = fill_params(record.path, location.params, string.format("named route '%s'", name))
                return _create_route(record, location, redirected_from)
            end
        elseif location.path then
            location.params = {}
            for _, path in ipairs(path_list) do
                local record = path_map[path]
                if match_route(record.regex, location.path, location.params) then
                    return _create_route(record, location, redirected_from)
                end
            end
        end
        -- no match
        return _create_route(nil, location)
    end

    return {
        match = match,
        add_routes = add_routes,
        remove_routes = remove_routes
    }
end