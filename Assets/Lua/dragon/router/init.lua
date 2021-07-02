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

function M.remove_routes(routes)
    router:remove_routes(routes)
end

function M.go(...)
    router:go(...)
end

function M.push(...)
    router:push(...)
end

function M.back(...)
    router:back(...)
end

function M.replace(...)
    router:replace(...)
end

function M.current()
    return router.history.current
end

function M.stack()
    return router.history.stack
end

function M.pending()
    return router.history.pending
end

function M.before_each(fn)
    return router:before_each(fn)
end

function M.after_each(fn)
    return router:after_each(fn)
end

function M.release()
    if M.view then
        M.view:release()
    end
end


return M