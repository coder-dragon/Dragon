--[[
    路由堆栈操作对象
]]
local dragon = require "dragon"
local array = dragon.array
local History = require("dragon.router.history.base")
local Stack = require("dragon.router.history.stack")

local M = {}

local function push(self, location, on_complete, on_abort)
    self:transition_to(location, function(route)
        self.stack:push(route)
        if on_complete then
            on_complete(route)
        end
    end, on_abort)
end

local function replace(self, location, on_complete, on_abort)
    self:transition_to(location, function(route)
        self.stack:replace(route)
        if on_complete then
            on_complete(route)
        end
    end, on_abort)
end

local function go(self, n, on_complete, on_abort)
    if type(n) == "string" then
        replace(self, n, function(route)
            self.stack:clear()
            self.stack:push(route)
            if on_complete then
                on_complete(route)
            end
        end, on_abort)
        return
    end

    local target = #self.stack.routes + n
    local route = self.stack:get(target)
    if not route then
        return
    end
    self:confirm_transition(route, function()
        self.stack:set_index(target)
        self:update_route(route)
        if on_complete then
            on_complete(route)
        end
    end, on_abort)
end

local function ensure_url()
    -- noop
end

function M.new(router, base)
    local self = History.new(router, base)
    self.stack = Stack.new(router)
    self.push = push
    self.replace = replace
    self.go = go
    self.get_current_location = get_current_location
    self.ensure_url = ensure_url
    return self
end

return M