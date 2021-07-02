--[[

]]

local dragon = require "dragon"

local M = dragon.class()

--- 获取当前view的层级
local function get_depth(self)
    local depth = 1
    local parent = self.parent
    while parent do
        parent = parent.parent
        depth = depth + 1
    end
    return depth
end

--- view构造函数
--- @param router table 路由管理器
--- @param parent table 父级view
function M:ctor(router, parent)
    assert(self ~= parent)
    self.children = {}
    self.router = router
    self.parent = parent
    self.instances = setmetatable({}, { __mode = "v"})
    self.unhooks = {}
    if parent then
        table.insert(parent.children, self)
    end
    
    --- 构造一个view的实例对象
    local cache = {}
    self.cache = cache
    local get_or_create_view = function(def)
        local cached = cache[def]
        if cached and not cached.released then
            return cached
        end
        local view_ctor
        if type(def) == "function" then
            --- component定义为方法则为构造函数
            view_ctor = def
        elseif def.__type == "object" then
            --- 如果是个class实例也就是view则共用此实例
            def._router_view = self
            return def
        else
            --- 如果是脚本的话则需要实现new方法来构造
            view_ctor = def.new
        end
        local view = view_ctor(def)
        view._router_view = self
        cache[def] = view
        return view
    end
    
    --- 注册 before_each 函数钩子
    local unhook
    unhook = router:before_each(function(to, from, next)
        if #to.matched == 0 then
            error("未定义的路由：" .. to.path)
        end
        next()
    end)
    table.insert(self.unhooks, unhook)

    --- 注册 after_each 函数钩子
    --- 在确认路由的回调中被调用
    --- 用于创建view实例
    unhook = router:after_each(function(to, from)
        local depth = get_depth(self)
        local matched = to.matched[depth]
        if not matched then
            -- 这级的路由没有任何匹配的组件
            return
        end
        if self.filter and not self.filter(to.matched) then
            -- 不符合过滤器的要求
            return
        end
        local components = matched.components
        for key, def in pairs(components) do
            local view = get_or_create_view(def)
            view:set_parent(self.container)
            self.instances[key] = view
            matched.instances[key] = view
        end
    end)
    table.insert(self.unhooks, unhook)

    --- 为当前路由组件创建和绑定新的view实例
    --- TODO: 这里没有看懂什么意思
    local route = router:current()
    local depth = get_depth(self)
    local matched = route.matched[depth]
    if not matched then
        return
    end
    local components = matched.components
    local instances = matched.instances
    if not components or not instances then
        return
    end

    for key, def in pairs(components) do
        if not instances[key] then
            instances[key] = get_or_create_view(def)
            instances[key]._router_view = self
        end
    end
end

--- 挂载view实例
--- @param container table view挂点
function M:mount(container)
    self.container = container
    local route = self.router:current()
    local depth = self:get_depth()
    local matched = route.matched[depth]
    if not matched then
        return
    end
    local instances = route.matched[depth].instances
    if not instances then
        return
    end
    for key, component in pairs(instances) do
        component:set_parent(container)
    end
end

--- 释放当前view
function M:release()
    for _, unhook in ipairs(self.unhooks) do
        unhook()
    end
    for _, child in ipairs(self.children) do
        child:release()
    end
    for def, view in pairs(self.cache) do
        view:release()
    end
    self.cache = nil
end

--- 获取当前view的层级
M.get_depth = get_depth

return M

