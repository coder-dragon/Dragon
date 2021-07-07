--[[
    UI模块
]]--

local blaze = require "blaze"
local yield = coroutine.yield

local M = {}

local empty
local keep
local leaving_count = 0
local elements = setmetatable({}, { __mode = "k" })

local function run_queue(start_coroutine, from_views, to_views, to, from)
    local consume = function(from_view)
        if not from_view.released then
            from_view.after_route_leave(from_view, to, from)
        end
        leaving_count = leaving_count - 1
    end

    for pos, from_view in ipairs(from_views) do
        if from_view then
            leaving_count = leaving_count + 1
            start_coroutine(consume, from_view)
        end
    end

    start_coroutine(function()
        -- 等所有界面都leave结束后再hide
        while leaving_count > 0 do
            yield()
        end
        for pos, from_view in ipairs(from_views) do
            local to_view = to_views[pos]
            if from_view and to_view and from_view ~= to_view then
                -- print("[DEBUG]hiding", from_view.res, dragon.dump(to_view, 5))
                from_view:hide()
            end
            if to_view and not to_view.released then
                start_coroutine(to_view.after_route_enter, to_view, to, from)
            end
        end
    end)
end

function M.init(app)
    M.app = app
    empty = M.app.ui.activity()
    keep = function(match, key)
        return M.app.router.view.instances[key]
    end
end

local function after_each(router_view, to, from)
    -- print("[DEBUG]to:", dragon.dump(to, 5))
    -- print("[DEBUG]from", dragon.dump(from, 5))

    local depth = router_view:get_depth()
    local layout = dragon.config.ui.layout
    local from_matched = from.matched[depth]
    local to_matched = to.matched[depth]
    local from_views = {}
    local to_views = {}

    for name, config in pairs(layout) do
        local from_view = from_matched and from_matched.instances[name]
        local to_view = to_matched and to_matched.instances[name]
        -- 顶层视图需要设置层级
        if depth == 1 then
            if to_view and config.layer then
                to_view:set_layer(config.layer)
            end
        end
        table.insert(from_views, from_view or false)
        table.insert(to_views, to_view or false)
    end

    local start_coroutine = M.app.coroutine.start
    start_coroutine(run_queue, start_coroutine, from_views, to_views, to, from)
end

function M.init_routes()
    local uiconfig = dragon.config.ui
    if not uiconfig then
        return
    end
    local routes = uiconfig.routes
    if not routes then
        return
    end

    M.add_routes(routes)

    local view = M.app.router.view
    M.app.router.after_each(function(to, from) after_each(view, to, from) end)
end

function M.init_floats()
    local uiconfig = dragon.config.ui
    if not uiconfig then
        return
    end
    local floats = uiconfig.floats
    if not floats then
        return
    end

    M.add_floats(floats)
end

function M.add_floats(floats)
    M.app.float.add_floats(floats)
end

function M.remove_floats(floats)
    M.app.float.remove_floats(floats)
end

function M.add_routes(routes)
    -- 将未定义的路由组件配置用默认值填充
    for _, route in ipairs(routes) do
        route.dynamics = {}
        if route.component then
            route.components = {
                default = route.component
            }
            route.component = nil
        end
        for name, config in pairs(dragon.config.ui.layout) do
            if not route.components[name] then
                if config.keep then
                    route.dynamics[name] = keep
                    route.components[name] = keep
                else
                    route.components[name] = empty
                end
            end
        end
    end
    M.app.router.add_routes(routes)
end

function M.remove_routes(routes)
    M.app.router.remove_routes(routes)
end

function M.create_router_view(filter)
    local ret = M.app.router.create_view(filter)
    ret.router:after_each(function(to, from)
        local current = M.app.router.current()
        if string.contains(current.matched[1].path, filter) then
            after_each(ret, to, from)
        end
    end)
    return ret
end

-- 定义一个界面视图组件
-- base 视图组件的基类
function M.activity(base)
    if not base then
        base = require "dragon.ui.activity"
    end
    local Class = dragon.class(base)
    return Class
end

-- 定一个视图组件
-- base 视图组件的基类
function M.element(base)
    if not base then
        base = require "dragon.ui.element"
    end
    local Class = dragon.class(base)
    return Class
end

-- 跟踪一个视图组件
-- 在UI模块释放时释放掉
function M.trace_element(element)
    elements[element] = true
end

function M.release()
    for element, v in pairs(elements) do
        if element.release then
            element:release()
        end
    end
end

return M