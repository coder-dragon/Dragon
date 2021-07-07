local observeable = require 'observeable'
local binding =  require 'binding'

local _M = {}

local type, setmetatable = type, setmetatable
local setfenv = setfenv or function(fn, env)
    local i = 1
    while true do
        local name = debug.getupvalue(fn, i)
        if name == '_ENV' then
            debug.upvaluejoin(fn, i, (function()
                return env
            end), 1)
            break
        elseif not name then
            break
        end
        i = i + 1
    end
    return fn
end

local function loadpackage(...)
    for _, loader in ipairs(package.searchers) do
        local func = loader(...)
        if type(func) == 'function' then
            return func
        end
    end
end

local function loadmodule(options, exports, app_name, name, do_not_load_data)
    local func = assert(loadpackage(string.format('%s.%s', app_name, name)), 'can not load module:' .. name)
    setfenv(func, setmetatable({}, {
        __index = function(t, k)
            return _G[k] or exports[k]
        end,
    }))
    local m = func()
    exports[name] = m.exports
    if not do_not_load_data then 
        options.data[name] = m.data
    end
    if m.commands then
        for k, v in pairs(m.commands) do
            options.commands[string.format('%s.%s', name, k)] = v
        end
    end
    if m.computed then
        local computed_watchs = options.computed[0]
        for k, v in pairs(m.computed) do
            local cname = string.format('%s.%s', name, k)
            options.computed[cname] = v
            local ccb = computed_watchs[cname]
            if ccb then
                for cb in pairs(ccb) do
                    cb()
                end
            end
        end
    end
end

local function app_init(options)
    local app_name = assert(options.name, 'app name require')
    
    for _, module_name in ipairs(options.modules or {}) do
        loadmodule(options, options.exports, app_name, module_name)
    end
end

--options = {
--    data = {},
--    computed = {},
--    commands = {},
--}

local function new(options)
    options = options or {}
    options.data = options.data or {}
    options.computed = options.computed or {}
    options.computed[0] = {}
    options.commands = options.commands or {}
    options.exports = {}
    
    if options.modules then
        app_init(options)
    end

    local observe = observeable.new(options.data)
    
    local function attach(el)
        return binding.bind(options.data, observe, options.computed, options.commands, el)
    end
    
    local function reload(module_name, reload_data)
        loadmodule(options, options.exports, options.name, module_name, not reload_data)
    end
    
    return attach, reload
end


_M.new = new

return _M