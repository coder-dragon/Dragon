--[[
    路由模块
]]--

local dragon = require "dragon"
local Router = require "dragon.router.router"
local View = require "dragon.router.view"

local log = dragon.logging.get("router")

local M = {}
M.view = nil

local router = nil

local function on_error(err)
    log.error(string.format("error:%s", err))
end

--- 模块初始化
--- @param app table dragon框架环境
function M.init(app)
    M.app = app
end

--- 创建view
--- @param parent table 父view实例
function M.create_view(parent, filter)
    if type(parent) == "string" then
        filter = parent
        parent = nil
    end
    local ret = View.new(router, parent or M.view)
    if filter then
        if type(filter) == "string" then
            ret.filter = function(matched)
                return matched[1].path == filter
            end
        elseif type(filter) == "function" then
            ret.filter = filter
        else
            error("invalid filter type " .. type(filter))
        end
    end
    return ret
end

--- 新增路由导航配置
--- @param routes table 路由导航配置
function M.add_routes(routes)
    if router then
        router:add_routes(routes)
    else
        router = Router.new(routes)
        router.app = M.app
    end
    if not M.view then
        M.view = M.create_view()
    end
end

--- 移除路由导航配置
--- @param routes table 路由导航配置
function M.remove_routes(routes)
    router:remove_routes(routes)
end

-- 清除堆栈并导航到指定位置
function M.go(...)
    router:go(...)
end

-- 导航到指定位置并压入堆栈
function M.push(...)
    router:push(...)
end

-- 返回到堆栈中的某级位置
-- n number:返回几次，默认为1
-- n function:依次从栈顶遍历回调，直到callback(route)返回真值
function M.back(...)
    router:back(...)
end

-- 导航到指定位置并替换掉堆栈顶部的路由记录
function M.replace(...)
    router:replace(...)
end

--- 获取当前路由状态信息
function M.current()
    return router.history.current
end

--- 获取路由堆栈
function M.stack()
    return router.history.stack
end

--- 获取当前挂起的路由
function M.pending()
    return router.history.pending
end

--- 注册 before_each 函数钩子
function M.before_each(fn)
    return router:before_each(fn)
end

--- 注册 after_each 函数钩子
function M.after_each(fn)
    return router:after_each(fn)
end

--- 释放
function M.release()
    if M.view then
        M.view:release()
    end
end


return M