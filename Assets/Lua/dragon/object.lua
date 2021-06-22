local M = {}

local function clone(target)
    local ret = {}
    for k, v in pairs(target) do
        ret[k] = v
    end
    return ret
end

local function deep_clone(target, cache)
    if type(target) ~= "table" then
        return target
    end

    cache = cache or {}
    if cache[target] then
        return cache[target]
    end

    local cloned = {}
    for k,v in pairs(target) do
        cloned[deep_clone(k, cache)] = deep_clone(v, cache)
    end

    cache[target] = cloned
    return cloned
end

local function freeze(target)
    print("TODO:freeze target")
    return target
end

local function keys(obj)
    local ret = {}
    for k,_ in pairs(obj) do
        ret[#ret + 1] = k
    end
    return ret
end

local function equal(ty1, ty2, ignore_mt)
    local ty1 = type(t1)
    local ty2 = type(t2)
    if ty1 ~= ty2 then
        return false
    end
    -- non-table types can be directly compared
    if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
    -- as well as tables which have the metamethod __eq
    local mt = getmetatable(t1)
    if not ignore_mt and mt and mt.__eq then return t1 == t2 end
    for k1, v1 in pairs(t1) do
        local v2 = t2[k1]
        if v2 == nil or not equal(v1,v2) then return false end
    end
    for k2, v2 in pairs(t2) do
        local v1 = t1[k2]
        if v1 == nil or not equal(v1,v2) then return false end
    end
    return true
end

local function assign(to, ...)
    assert(to)
    local args = table.pack(...)
    for _, from in ipairs(args) do
        for k, v in pairs(from) do
            to[k] = v
        end
    end
    return to
end

function M.is_object(obj)
    return obj and type(obj) == "table"
end

M.equal = equal
M.clone = clone
M.deep_clone = deep_clone
M.freeze = freeze
M.assign = assign

return M