--[[
    路由导航器

    导航流程：
    1、导航触发
        当前组件 before_route_leave
        全局钩子 before_each
        重用组件 before_route_update
    2、解析目标组件
        目标组件 before_route_enter
    3、导航确认
        全局钩子 after_each
        当前组件 after_route_leave
        目标组件 after_route_enter

    参考链接：
    https://router.vuejs.org/zh/guide/advanced/navigation-guards.html#%E5%AE%8C%E6%95%B4%E7%9A%84%E5%AF%BC%E8%88%AA%E8%A7%A3%E6%9E%90%E6%B5%81%E7%A8%8B
]] --

local dragon = require "dragon"
local create_matcher = require "dragon.router.create-matcher"
local History = require "dragon.router.history.abstract"

local M = {}
M.__index = M

function M.new(routes)
    local self = {}
    self.before_hooks = {}
    self.after_hooks = {}
    self.resolve_hooks = {}
    self.matcher = create_matcher(routes or {}, self)
    self.history = History.new(self)
    setmetatable(self, M)
    self:go("/")
    return self
end

-- 清除堆栈并导航到指定位置
function M:go(location, on_complete, on_abort)
    self.history:go(location, on_complete, on_abort)
end

-- 导航到指定位置并压入堆栈
function M:push(location, on_complete, on_abort)
    self.history:push(location, on_complete, on_abort)
end

-- 导航到指定位置并替换掉堆栈顶部的路由记录
function M:replace(location, on_complete, on_abort)
    self.history:replace(location, on_complete, on_abort)
end

-- 返回到堆栈中的某级位置
-- n number:返回几次，默认为1
-- n function:依次从栈顶遍历回调，直到callback(route)返回真值
function M:back(n, on_complete, on_abort)
    if type(n) == "function" then
        local callback = n
        n = 0
        local stack = self.history.stack
        for i=#stack.routes, 1, -1 do
            local route = stack.routes[i]
            if callback(route) then
                break
            end
            n = n + 1
        end
        if n == 0 then
            return
        end
    else
        n = n or 1
    end
    self.history:go(-n, on_complete, on_abort)
end

-- 新增路由导航配置
function M:add_routes(routes)
    self.matcher.add_routes(routes)
end

-- 删除路由导航配置
function M:remove_routes(routes)
    self.matcher.remove_routes(routes)
end

-- 获取当前路由
function M:current()
    return self.history.current
end

-- 获取路由记录的堆栈
function M:stack()
    return self.history.stack
end

function M:match(raw, current, redirected_from)
    return self.matcher.match(raw, current, redirected_from)
end

-- =========== 全局钩子 ===========

local function register_hook(list, fn)
    table.insert(list, fn)
    return function()
        for i, v in ipairs(list) do
            if v == fn then
                table.remove(list, i)
                return
            end
        end
    end
end

function M:before_each(fn)
    return register_hook(self.before_hooks, fn)
end

function M:before_resolve(fn)
    return register_hook(self.resolve_hooks, fn)
end

function M:after_each(fn)
    return register_hook(self.after_hooks, fn)
end

function M:on_error(fn)
    return self.history:on_error(fn)
end

return M
