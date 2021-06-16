local dragon = require "dragon"
local create_store = require "blaze.store.create-store"
local log = dragon.logging.get("store")

local M = {}

-- 通过 store.xxx 查找并创建对应的store模块
function M.make_store_searcher(resolve)
    return function(t, name)
        local path = resolve(name)
        if not dragon.package_exists(path) then
            return
        end
        local ok, resutl = pcall(function()
            local options = require(path)
            options.name = name
            return create_store(options)
        end)
        if ok then
            rawset(t, name, resutl)
            return result
        else
            log.error(string.format("cteate store '%s' failed:%s", name, result))
        end
    end
end

setmetatable(M, {__index = M.make_store_searcher(function(name)
    return "store"..name
end)})

return M