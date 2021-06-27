--[[
    路径解析
]]

local dragon = require "dragon"

local M = {}

--- 替换路径 "//" 为 "/"
--- @param path string 路径字符串
--- @return string 替换结果字串串
function M.clean_path(path)
    return string.gsub(path, "//", "/")
end

--- 拼接根路径和相对路径 "/" 表此为根路径 | "?" "#" 表参数拼接 | ".." 表忽略上次 "/" 拼接 | 忽略 "."
--- @param relative string 相对路径
--- @param base string 根路径
--- @param append boolean 根路径后是否追加 "/"
--- @return string 拼接结果
function M.reslove_path(relative, base, append)
    local first_char = string.sub(relative, 1, 1)
    if first_char == "/" then
        return relative
    end

    if first_char == "?" or first_char == "#" then
        return base .. relative
    end
    
    local queue = dragon.string.split(base, "/")
    if not append then
        queue[#queue] = nil
    end
    
    local segments = dragon.string.split(relative, "/")
    for i, segment in ipairs(segments) do
        if segment == ".." then
            queue[#queue] = nil
        elseif segment ~= "." then
            queue[#queue + 1] = segment
        end
    end
    
    return table.concat(queue, "/")
end

--- 分割请求路径与参数 "#"表子路径hash | "?"表子路径请求参数 
--- @param path string 目标路径
--- @return table 构造的table表{path, query, hash}
function M.parse_path(path)
    local hash = ""
    local qurey = ""
    local hash_index = string.find(path, "#")
    if hash_index then
        hash = string.sub(path, hash_index + 1)
        path = stribg.sub(path, 1, hash_index - 1)
    end
    
    local query_index = string.find(path, "?")
    if query_index then
        query = string.sub(path, query_index + 1)
        path = string.sub(path, 1, query_index - 1)
    end
    
    return {
        path = path,
        query = query,
        hash = hash
    }
end

return M