local setmetatable, getmetatable, rawset, rawget, pairs, type, ipairs = setmetatable, getmetatable, rawset, rawget, pairs, type, ipairs
local insert = table.insert
local find, format, sub, gsub = string.find, string.format, string.sub, string.gsub

local _M = {}

local function append_key(path, key)
    if not path or path == '' then return key end
    if type(key) ~= 'number' and type(key) ~= 'string' then error('not support key type' .. type(key)) end
    return (type(key) == 'number') and (path .. '[' .. key .. ']') or (path .. '.'..key)
end

local mt_flag = {}

local function gen_set_callback(callback_info, field_path)
    return function()
        local callbacks = callback_info[field_path]
        if not callbacks then return end
        for callback in pairs(callbacks) do
            callback()
        end
    end
end

local read_report

local function observeable_init(obj, root, path, callback_info)
    if type(obj) ~= 'table' then return obj end
    
    local org_mt = getmetatable(obj)
    if org_mt and org_mt.__flag == mt_flag then return obj end

    local _obj = {}
    local field_callbacks = {}
    local self_callback = gen_set_callback(callback_info, path)
    
    for k,v in pairs(obj) do
        local field_path = append_key(path, k)
        _obj[k] = (type(v) == 'table') and observeable_init(v, root, field_path, callback_info) or v
        rawset(obj, k, nil) --clear org obj
        field_callbacks[k] = gen_set_callback(callback_info, field_path)
    end

    setmetatable(obj, {
        __flag = mt_flag,
        __raw = _obj,
        __index = function(t, k)
            if read_report then read_report(append_key(path, k)) end
            return _obj[k]
        end,
        __newindex = function(t, k, v)
            local old = _obj[k]
            _obj[k] = (type(v) == 'table') and observeable_init(v, root, append_key(path, k), callback_info) or v
            
            if old == v then return end
            
            local callback = field_callbacks[k]
            
            if not callback then
                callback = gen_set_callback(callback_info, append_key(path, k))
                field_callbacks[k] = callback
            end
            
            if v == nil then
               field_callbacks[k] = nil
            end
            
            callback()
            
            if old == nil or v == nil then
                self_callback()
            end
        end,
    })

    return obj
end

local parse_path = (require 'xuui_utils').parse_path

local function to_ordinary_table(tbl)
    if type(tbl) ~= 'table' then
        return tbl
    end
    
    local mt = getmetatable(tbl)
    local raw = mt and mt.__raw
    if not raw then
        return tbl
    end
    
    local ret = {}
    
    for k, v in pairs(raw) do
        ret[k] = to_ordinary_table(v)
    end
    
    return ret
end

local function init_dir(data, keys)
    for i, key in ipairs(keys) do
        if i ~= #keys then
            data[key] = data[key] or {}
        end
    end
end

local function new(data)
    local callback_info = {}
    observeable_init(data, data, "", callback_info)
    return {
        watch = function(self, path, callback)
            local keys = parse_path(path)
            init_dir(data, keys)
            local function get(obj)
                for _, key in ipairs(keys) do
                    if not obj then return end
                    obj = obj[key]
                end
                return obj
            end
            
            local value = get(data)
            
            local function real_callback()
                local old = value
                value = get(data) -- new value
                
                if value == old and type(value) ~= 'table' then return end
                
                callback(root, value, old)
            end
            
            local pp = ''
            for _, key in ipairs(keys) do
                pp = append_key(pp, key)
                callback_info[pp] = callback_info[pp] or {}
                callback_info[pp][real_callback] = true
            end
            
            return real_callback
        end,
        unwatch = function(self, real_callback)
            for _, cbs in pairs(callback_info) do
                cbs[real_callback] = nil
            end
        end,
        setter = function(self, path)
            local keys = parse_path(path)
            local key_len = #keys
            return function(obj, value)
                for i, key in ipairs(keys) do
                    if not obj then return end
                    if i == key_len then
                        obj[key] = value
                    else
                        obj = obj[key]
                    end
                end
            end
        end,
        getter = function(self, path)
            local keys = parse_path(path)
            return function(obj)
                for _, key in ipairs(keys) do
                    if not obj then return end
                    obj = obj[key]
                end
                return obj
            end
        end,
        read_report = function(self, callback)
            read_report = callback
        end,
        
        raw = function(self, tbl)
            return to_ordinary_table(tbl)
        end
    }
end

_M.new = new
_M.raw = to_ordinary_table

----------------------------test----------------------------

local function test()
    parse_path('a.b.c')
    parse_path('a.b.cde')
    parse_path('a')
    parse_path('a[1]')
    parse_path('[1]')
    parse_path('a.b[1]')
    parse_path('a.b[1].cd')
    print(pcall(parse_path, 'a.b[1.cd'))
    print(pcall(parse_path, 'a.b[aa]'))
    
    
    local data = {
        someStr = 'Hello ',
        child = {
            someStr = 'World !'
        }
    }
    
    local observe = new(data)
    
    observe:watch('someStr', function(root, value, old)
        print('someStr changed', value, old)
    end)
    
    observe:watch('child.someStr', function(root, value, old)
        print('child.someStr changed', value, old)
    end)
    
    observe:watch('child', function(root, value, old)
        print('child changed', value, old)
    end)
    
    print('---------------------')
    data.someStr = 'Hello John'
    
    print('---------------------')
    data.child.someStr = '!!!'
    
    print('---------------------')
    data.child = nil
    
    print('---------------------')
    data.child = {someStr = 100}
    
    print('---------------------')
    data.child.aaa = 1000
    
    print('---------------------')
    data.child = data.child
end

if arg and arg[1] == 'test' then
    test()
end

return _M