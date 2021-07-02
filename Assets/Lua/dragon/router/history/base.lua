--[[
    基础对象，用于导航路由，执行路由守卫，以及生成一个新的route对象
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

--- 将匹配到的路由记录分类
--- @param current table 当前的路记录
--- @param next table 导航的路由记录
--- @return table 经过分类的路由记录 更新，激活，失活
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
--- @param is_valid boolean 当前路由是否合法
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

--- poll方法，当vm实例被创建以后则调用callback
--- @param cb function 路由守卫的回调函数
--- @param instances table 路由vm实例
--- @param key string 路由组件名
--- @param is_valid function 是否有效
local function poll(cb, instances, key, is_valid)
    if instances[key] and not instances[key]._is_being_destroyed then
        cb(instances[key])
    elseif is_valid() then
        dragon.timer.start(function()
            poll(cb, instances, key, is_valid)
        end, 0.016)
    end
end

--- 构造函数
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

--- 监听回调
--- @param cb function 回调函数
function M:listen(cb)
    self.cb = cb
end

--- 路由激活后的回调
--- @param cb function 成功回调函数
--- @param error_cb function 错误回调函数
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

--- 插入错误回调
--- @param error_cb function 错误回调函数
function M:on_error(error_cb)
    table.insert(self.error_cbs, error_cb)
end

--- 导航路由
--- @param location table 路由导航定位
--- @param on_complete function 导航完成回调
--- @param on_abort function 导航中止回调
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

--- 确认路由导航
--- @param route table 当前路由对象
--- @param on_complete function 导航完成回调
--- @param on_abort function 导航中止回调
function M:confirm_transition(route, on_complete, on_abort)
    local current = self.current
    --- 路由终止回调
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
    
    --- 是当前路由则终止路由
    if route:equals(current) and #route.matched == #current.matched then
        self:ensure_url()
        return abort()
    end
    
    --- 遍历整理出所有的comonent 更新，失活，激活
    local resolved = resolve_queue(self.current.matched, route.matched)
    local updated = resolved.updated
    local deactivated = resolved.deactivated
    local activated = resolved.activated

    --- 提取所有component上的函数钩子
    local queue = array.concat(
            extract_leave_guards(deactivated),
            self.router.before_hooks,
            extract_update_hooks(updated),
            array.map(activated, function(m) return m.before_enter end)
    )
    queue[#queue+1] = resolve_async_components(activated)
    
    --- 用于依次执行hook函数的迭代器，参考dragon.router.util.async
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
        --- 注入
        local queue = array.concat(enter_guards, self.router.resolve_hooks)
        run_queue(queue, iterator, function()
            if self.pending ~= route then
                return abort()
            end
            self.pending = nil
            on_complete(route)
            dragon.coroutine.start(function()
                coroutine.yield()
                for _,cb in ipairs(post_enter_cbs) do
                    --- 此回调函数为执行poll函数，
                    ---每帧轮询，直到view被生成后
                    ---给 before_router_enter钩子函数的的回调传入view实例
                    cb()
                end
            end)
        end)
    end)
end

--- 更新路由 在确认路由的回调中调用
--- @param route table 路由对象
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