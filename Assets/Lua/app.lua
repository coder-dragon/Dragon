local dragon = require "dragon"

local App = {}

function App.start()
    self.ui.init_routes()
    self.router.go("/main")
end

local function module_search(t, name)
    local ret = t[name]
    local ok, result
    local inited = false
    if ret == nil then
        ok, result = true, dragon[name]
        inited = true
    elseif type(ret) == "table" then
        ok, result = true, ret
    elseif type(ret) == "string" then
        ok, result = pcall(require, ret)
    elseif type(ret) == "function" then
        ok, result = pcall(ret)
    end

    if ok then
        if result == nil then
            error(string.format("%s模块不存在", name))
        end
        rawset(t, name, result)
        if not inited then
            t.loaded_modules[name] = result
            if result.init and type(result.init) == "function" then
                ok = pcall(result.init, t)
                if not ok then
                    error(string.format("%s模块init 失败", name))
                end
            end
        end
        return result
    else
        error(string.format("加载%s模块失败 错误:%s", name, result))
    end
end

return setmetatable(App, { __index = module_search})