--[[
    初始化dragon模块的功能
    框架工具集合
]]

-- 空表，并且无法对这个表进行赋值操作，适用于需要传空表的情况
local empty = setmetatable({}, {
    __newindex = function(t, k , v)
        error("should not set any value to this table")
    end
})

-- 空方法，适用于需要传空方法的情况
local function noop()
end

-- 将指定的表结构作为子符串返回
-- options          为数字时表示嵌套层级
-- options.nesting  嵌套层级
-- options.desc     描述文本
local function dump(value, options)
    local desc
    local nesting

    if type(options) == "number" then
        nesting = options
    elseif type(options) == "table" then
        desc = options.nesting
        nesting = options.nesting
    end

    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result = {}

    local function dump_value(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local function _dump(value, desc, indent, nest, keylen)
        desc = desc or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string.rep(" ", keylen - string.len(dump_value(desc)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, dump_value(desc), spc, dump_value(value))
        elseif lookupTable[tostring(value)] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, dump_value(desc), spc)
        else
            lookupTable[tostring(value)] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, dump_value(desc))
            else
                result[#result +1 ] = string.format("%s%s = {", indent, dump_value(desc))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = dump_value(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                    return false
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end

    _dump(value, desc, "- ", 1)

    return table.concat(result, "\n")
end

-- 判断一个对象是否为nil，适用于UnityObject已被摧毁的情况
local function is_nil(obj)
    return obj == nil or obj:IsNull()
end

-- 调用指定的回调，若回调不存在则忽略
local function invoke(func, ...)
    if func then
        return func(...)
    end
end

local def_modules = {}
local loaded_module = {}

-- 通过dragon.xxx的索引模块，不用使用传统的require脚本的形式
local function module_search(t, name)
    if loaded_module[name] then
        return loaded_module[name]
    end
    local ret = def_modules[name]
    local ok, result
    if ret == nil then
        ok, result = pcall(require, "dragon."..name)
    elseif type(ret) == "table" then
        ok, result = true, ret
    elseif type(ret) == "function" then
        ok, result = pcall(ret)
    elseif type(ret) == "string" then
        ok, result = pcall(require, name)
    else
        error(string.format("lua module is not found：%s", name))
    end
    if ok then
        loaded_module[name] = ret
        rawset(t, name, result)
        if result.init then
            result.init(t)
        end
        return result
    else
        error(string.format("load lua module failed：%s  ->  %s", name, result))
    end
end

-- 更换自定义模块
local function use(name, module)
    assert(not def_modules[name], "自定义模块已经存在:" .. name)
    def_modules[name] = module
end

-- 判断模块是否存在
local function package_exists(name)
    assert(name)
    if package.loaded(name) then
        return true
    end

    for _, searcher in ipairs(package.searchers) do
        local loader = searcher(name)
        if type(loader) == "function" then
            package.preload[name] = loader
            return true
        end
    end
    return false
end

return setmetatable({
    class = require "dragon.core.class",
    promise = require "dragon.core.promise",
    empty = empty,
    noop = noop,
    is_nil = is_nil,
    invoke = invoke,
    dump = dump,
    use = use,
    module_search = module_search,
    package_exists = package_exists
}, {__index = module_search})