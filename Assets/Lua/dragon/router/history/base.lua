--[[
    
]]

local dragon = require "dragon"
local promise = dragon.promise
local array = dragon.array
local slice = array.slice
local is_array = array.is_array

local log = dragon.logging.get("base")

local run_queue = require("dragon.router.util.async").run_queue

local resolve_components = require "dragon.router.util.resolve-components"
local flatten = resolve_components.flatten
local flat_map_components = resolve_components.flat_map_components
local resolve_async_components = resolve_components.resolve_async_components

local START = require("dragon.router.route").START

local M = {}
M.__index = M

local function resolve_queue(current, next)
    local i = 1
    local max = math.max(#current, #next)
    while i <= max do
        if current[i] ~= next[i] then
            break
        end
        i = i + 1
    end
    i = i - 1
    return {
        updated = slice(next, 1, i),
        activated = slice(next, i),
        deactivated = slice(current, i)
    }
end

--- 绑定路由守卫
--- @param guard function 路由守卫
--- @param instance table 当前路由实例
local function bind_guard(guard, instance)
    if instance then
        return function(...)
            return guard(instance, ...)
        end
    end
end

--- 绑定 "before_route_enter" 路由守卫
--- @param guard function 路由守卫
--- @param match table 匹配的路由记录
--- @param key string component组件名
--- @param cbs table 回调方法列表
--- @param is_valid boolean TODO: 参数未知
local function bind_enter_guard(guard, match, key, cbs, is_valid)
    return function(to, from, next)
        return guard(to, from, function(cb)
            next(cb)
            if type(cb) == "function" then
                table.insert(cbs, function()
                    poll(cb, match.instances, key, is_valid)
                end)
            end
        end)
    end
end

--- 提取component实例中的路由守卫
--- @param def table component实例
--- @param key string 路由守卫方法名
local function extract_guard(def, key)
    return def[key]
end

--- 提取路由中所有的component实例的路由守卫
--- @param records table 路由记录
--- @param name string 路由守卫方法名
--- @param bind function 绑定路由守卫的方法
--- @param reverse boolean 是否反转绑定顺序
--- @return table 路由守卫列表
local function extract_guards(records, name, bind, reverse)
    local guards = flat_map_components(records, function(def, instance, match, key)
        local guard = extract_guard(def, name)
        if guard then
            return is_array(guard) 
                    and array.map(guard, function(g) return bind(g, instance, match, key) end)
                    or { bind(guard, instance, match, key) }
        end
    end)
    return flatten(reverse and array.reverse(guards) or guards)
end

--- 提取所有 "before_route_leave" 路由守卫
--- @param deactivated table 当前失效的路由记录列表
--- @return table 所有失效路由记录中的 "before_route_leave" 路由守卫列表
local function extract_leave_guards(deactivated)
    return extract_guards(deactivated, "before_route_leave", bind_guard, true)
end

--- 提取所有 "before_route_update" 路由守卫
--- @param updated table 当前更新的路由记录
--- @return table 所有更新路由记录中的 "before_route_update" 路由守卫列表
local function extract_update_hooks(updated)
    return extract_guards(updated, "before_route_update", bind_guard)
end

--- 提取所有 "before_route_enter" 路由守卫
--- @param activated table 当前被激活的路由记录
--- @return table 所有激活路由记录中的 "before_route_enter" 路由守卫列表
local function extract_enter_guards(activated, cbs, is_valid)
    return extract_guards(activated, "before_route_enter", function(guard, _, match, key)
        return bind_enter_guard(guard, match, key, cbs, is_valid)
    end)
end

local function poll(cb, instances, key, is_valid)
    if instances[key] and not instances[key]._is_being_destroyed then
        cb(instances[key])
    elseif is_valid() then
        dragon.timer.start(function()
            poll(cb, instances, key, is_valid)
        end, 0.016)
    end
end

function M.new(router, base)
    local self = {
        router = router,
        base = base,
        current = START,
        pending = nil,
        ready = false,
        ready_cbs = {},
        ready_error_cbs = {},
        error_cbs = {}
    }
    setmetatable(self, M)
    return self
end

function M:listen(cb)
    self.cb = cb
end

function M:on_ready(cb, error_cb)
    if self.ready then
        cb()
    else
        table.insert(self.ready_cbs, cb)
        if error_cb then
            table.insert(self.ready_error_cbs, error_cb)
        end
    end
end

function M:on_error(error_cb)
    table.insert(self.error_cbs, error_cb)
end

function M:transition_to(location, on_complete, on_abort)
    local route = self.router:match(location, self.current)
    self:confirm_transition(route, function()
        self:update_route(route)
        if on_complete then
            on_complete(route)
        end
        self:ensure_url()

        if not self.ready then
            self.ready = true
            for _,cb in ipairs(self.ready_cbs) do
                cb(route)
            end
        end
    end, function(err)
        if on_abort then on_abort(err) end
        if err and not self.ready then
            self.ready = true
            for _, cb in ipairs(self.ready_error_cbs) do
                cb(err)
            end
        end
    end)
end

function M:confirm_transition(route, on_complete, on_abort)
    local current = self.current
    local abort = function(err)
        if err then
            if #self.error_cbs > 0 then
                for _, cb in ipairs(self.error_cbs) do
                    cb(err)
                end
            else
                log.warn(string.format("uncaught error during route navigation:%s", err))
            end
        end
        if on_abort then on_abort(err) end
    end

    if route:equals(current) and #route.matched == #current.matched then
        self:ensure_url()
        return abort()
    end

    local resolved = resolve_queue(self.current.matched, route.matched)
    local updated = resolved.updated
    local deactivated = resolved.deactivated
    local activated = resolved.activated

    local queue = array.concat(
            extract_leave_guards(deactivated),
            self.router.before_hooks,
            extract_update_hooks(updated),
            array.map(activated, function(m) return m.before_enter end)
    )
    queue[#queue+1] = resolve_async_components(activated)
    self.pending = route
    local iterator = function(hook, next)
        if self.pending ~= route then
            return abort()
        end
        xpcall(function()
            hook(route, current, function(to)
                if to == false then
                    -- next(false) -> abort navigation, ensure current URL
                    self:ensure_url(true)
                    abort(false)
                elseif promise.is_promise(to) then
                    to:next(next, function()
                        self:ensure_url(true)
                        abort(false)
                    end)
                elseif type(to) == "string" or (type(to) == "table" and (type(to.path) == "string" or type(to.name) == "string")) then
                    abort()
                    if type(to) == "table" and to.replace then
                        self:replace(to)
                    else
                        self:push(to)
                    end
                else
                    next(to)
                end
            end)
        end, function(err)
            abort(err .. "\n" .. debug.traceback())
        end)
    end

    run_queue(queue, iterator, function()
        local post_enter_cbs = {}
        local is_valid = function() return self.current == route end
        local enter_guards = extract_enter_guards(activated, post_enter_cbs, is_valid)
        local queue = array.concat(enter_guards, self.router.resolve_hooks)
        run_queue(queue, iterator, function()
            if self.pending ~= route then
                return abort()
            end
            self.pending = nil
            on_complete(route)
            if self.router.app then
                self.router.app.coroutine.start(function()
                    coroutine.yield()
                    for _,cb in ipairs(post_enter_cbs) do
                        cb()
                    end
                end)
            end
        end)
    end)
end

function M:update_route(route)
    local prev = self.current
    self.current = route
    if self.cb then
        self.cb(route)
    end
    for _, hook in ipairs(self.router.after_hooks) do
        if hook then hook(route, prev) end
    end
end

return M