local dragon = require "dragon"

local M = {}
M.__index = M

function M.new(routes)
    local self = {}
    self.before_hooks = {}
    self.after_hooks = {}
    self.resolve_hooks = {}
    self.matcher = nil
    self.history = nil
    setmetatable(self, M)
    self:go("/")
    return self
end

-- 清除堆栈并导航到指定位置
function M:go(location, on_complete, on_abort)
    
end

-- 导航到指定位置并压入堆栈
function M:push(location, on_complete, on_abort)
    
end

-- 导航到指定位置并替换到堆栈顶部的路由记录
function M:replace(location, on_complete, on_abort)
    
end

-- 返回到堆栈中的某级位置
function M:back(n, on_complete, on_abort)
    
end

-- 新增路由到导航配置
function M:add_routes(routes)
    
end

--获取当前路由
function M:current()
    
end

-- 获取当前路由记录的堆栈
function M:stack()
    
end


function M:match(raw, current, redirected_from)
    
end

-- =============== 全局钩子 ===============

-- 注册钩子函数
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

function M:before_reaolve(fn)
    return register_hook(self.reaolve_hooks, fn)
end

function M:after_each(fn)
    return register_hook(self.after_hooks, fn)
end

function M:on_error(fn)
    
end

return M