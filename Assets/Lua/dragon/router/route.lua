--[[
    一个路由对象 (route object) 表示当前激活的路由的状态信息，包含了当前路由路径（location）解析得到的信息，还有匹配到的路由记录 (route records)。
    路由对象是不可变 (immutable) 的，每次成功的导航后都会产生一个新的对象。

    参考链接：https://router.vuejs.org/zh/api/#%E8%B7%AF%E7%94%B1%E5%AF%B9%E8%B1%A1
]]--

local dragon = require "dragon"
local object = dragon.object
local stringify_query = require("dragon.router.util.query").stringify_query

local M = {}
M.__index = M

--- 平铺路由记录和他的父节点
--- @param record table 路由记录
--- @return table 路由记录列表
local function format_match(record)
    local ret = {}
    while record do
        table.insert(ret, 1, record)
        record = record.parent
    end
    return ret
end

--- 拼接路径并字符化请求参数
--- @param args table 路径格式化kv对象
--- @return string 拼接参数后的全路径
local function get_full_path(args)
    local path = args.path
    local query = args.query
    local stringify = stringify_query
    return (path or "/") .. stringify(query)
end

--- 路由对象构造函数
--- @param record table 路由记录
--- @param location table 格式化后的路径kv表
--- @param redirected_from string 重定向路径来源路由记录
function M.new(record, location, redirected_from)
    local query = location.query or {}
    pcall(function() query = object.deep_clone(query) end)
    
    local self = {
        name = location.name or (record and record.name),
        meta = (record and record.meta) or {},
        path = location.path or "/",
        query = query,
        params = location.params or {},
        full_path = get_full_path(location),
        matched = record and format_match(record) or {},
        redirected_from = redirected_from
    }
    setmetatable(self, M)
    
    return self
end

--- 比较两个路由对象是否一致
--- @param other table 需要进行比较的路由对象
function M:equals(other)
    local a = self
    local b = other
    if b == M.START then
        return a == b
    elseif not b then
        return false
    elseif a.path and b.path then
        return (
                a.path == b.path and 
                        object.equal(a.query, b.query)
        )
    elseif a.name and b.name then
        return (
                a.name == b.name and 
                        object.equal(a.query, b.query) and 
                        object.equal(a.params, b.params)
        )
    end
    return false
end

M.START = M.new(nil, { path = "/" })

return M