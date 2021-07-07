local collector = require 'collector'
local observeable = require 'observeable'

local _M = {}

local load = load or loadstring
local is_template = (require 'xuui_utils').is_template
local compile_template = (require 'xuui_utils').compile_template

local function listen_to(data, observe, computed, el, cbs, ccbs)
    local bind_to = assert(el.BindTo, 'invalid BindTo:' .. el.BindTo)
    local module_name
    if bind_to:find('%.') then
        module_name = bind_to:sub(1, bind_to:find("%.") - 1)
    end
    local is_computed = not not computed[bind_to]
    local is_computed_bind = is_template(bind_to)
    if is_computed or is_computed_bind then
        local watched = {}
        local to_watch = {}
        
        local function read_watch(path)
            if not watched[path] then
                table.insert(to_watch, path)
                watched[path] = true
            end
        end
        
        local compiled
        
        if is_computed_bind then
            compiled = compile_template(bind_to)
        end
        
        local function set_and_watch()
            local tmpdata = (is_computed and module_name) and data[module_name] or data
            local get = is_computed_bind and compiled or computed[bind_to]
            observe:read_report(read_watch)
            local value = observeable.raw(get(tmpdata))
            observe:read_report()
            --print('computed', bind_to, value)
            el.Value = value
            
            if #to_watch > 0 then
                for _, path in ipairs(to_watch) do
                    table.insert(cbs, observe:watch(path, set_and_watch))
                end
                to_watch = {}
            end
        end
        
        if module_name and not is_computed_bind then
            table.insert(ccbs, set_and_watch)
            local computed_watchs = computed[0]
            computed_watchs[bind_to] = computed_watchs[bind_to] or {}
            computed_watchs[bind_to][set_and_watch] = true
        end
        
        set_and_watch()
    else
        el.Value = observeable.raw(observe:getter(bind_to)(data))
        local cb = observe:watch(bind_to, function(_, value, old)
            el.Value = observeable.raw(value)
        end)
        table.insert(cbs, cb)
    end
end

local function watch_to(data, observe, el)
    local bind_to = assert(el.BindTo, 'invalid BindTo:' .. el.BindTo)
    local set = observe:setter(bind_to)
    el.OnValueChange = function(value)
        set(data, value)
    end
end

local function bind_action(data, commands, el)
    local bind_to = assert(el.BindTo, 'invalid BindTo:' .. el.BindTo)
    local module_name
    if bind_to:find('%.') then
        module_name = bind_to:sub(1, bind_to:find("%.") - 1)
    end
    local func = assert(commands[bind_to], 'invalid BindTo:' .. bind_to)
    if module_name then
        el.OnAction = function(...)
            commands[bind_to](data[module_name], ...)
        end
    else
        el.OnAction = function(...)
            func(data, ...)
        end
    end
end



function _M.bind(data, observe, computed, commands, root)
    local bindings = collector.collect(root)
    local cbs = {}
    local ccbs = {}
    for _, obj in ipairs(bindings[1]) do
        listen_to(data, observe, computed, obj, cbs, ccbs)
    end
    
    for _, obj in ipairs(bindings[2]) do
        watch_to(data, observe, obj)
    end
    
    for _, obj in ipairs(bindings[3]) do
        bind_action(data, commands, obj)
    end
    
    local function detach()
        for _, cb in ipairs(cbs) do
            observe:unwatch(cb)
        end
        for _, obj in ipairs(bindings[2]) do
            obj.OnValueChange = nil
        end
        for _, obj in ipairs(bindings[3]) do
            obj.OnAction = nil
        end
        local computed_watchs = computed[0]
        for _, ccb in ipairs(ccbs) do
            computed_watchs[ccb] = nil
        end
    end
    return detach
end

return _M
