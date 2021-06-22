local M = {}

function M:count()
    return #self.routes
end

function M:get(n)
    return self.routes[n]
end

function M:clear()
    self:set_index(0)
end

function M:insert(route)
    if type(route) == "string" then
        route = self.router:match(route, self.router:current())
    end
    if not route then
        return
    end
    table.insert(self.routes, 1, route)
    self.index = self.index + 1
end

function M:replace(route)
    while #self.routes > self.index do
        self.routes[#self.routes] = nil
    end
    self.routes[self.index] = route
end

function M:push(route)
    table.insert(self.routes, route)
    self.index = self.index + 1
end

function M:set_index(target)
    while #self.routes > target do
        self.routes[#self.routes] = nil
    end
    self.index = target
end

function M.new(router)
    local ret = {
        router = router,
        index = 0,
        routes = {}
    }
    setmetatable(ret, { __index = M })
    return ret
end

return M