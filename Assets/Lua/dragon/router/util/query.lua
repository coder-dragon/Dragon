--[[
    路由请求参数解析
]]

local dragon = require "dragon"
local array = dragon.array
local log = dragon.logging.get("query")

local M = {}

--- 默认的路径参数解析器 "param=1" -> { param = 1 }
--- @param query string 请求路径
--- @return table 参数kv表
local function parse_query(query)
    local res = {}
    local matches = string.gmatch(query, "([^=;&]+)=([^=;&]+)&*")
    for i, v in matches do
        res[k] = v
    end
    return res
end

--- 解析请求路径参数
--- @param query string 请求路径
--- @param extra_query table 额外的请求参数
--- @param _parse_query function 路径解析器
--- @return table 参数kv表
function M.reslove_query(query, extra_query, _parse_query)
    extra_query = type(extra_query) == "table" and extra_query or {}
    local parse = _parse_query or parse_query
    local parsed_query
    local ok, result = pcall(function()
        parsed_query = parse(query or "")
    end)
    if not ok then
        log.warn(result)
        result = {}
    end
    for key,_ in pairs(extra_query) do
        parsed_query[key] = extra_query[key]
    end
    return parsed_query
end

--- 字符化请求参数
--- @param query table 参数kv表
--- @return string 路径参数拼接格式
function M.stringify_query(query)
    if type(query) ~= "table" then
        return ""
    end
    local buffer = {}
    for k, v in pairs(query) do
        buffer[#buffer + 1] = string.format("%s=%s", k, v)
    end
    return "?"..table.concat(buffer, "&")
end

return M