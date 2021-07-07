local dragon = require "dragon"
local log = dragon.logging.get("demo")
local M = {}

--- 日志模块
function M:log_test()
    log.debug("日志模块测试成功")
end

--- 加载gameobject
function M:load_gameobject()
    local go
    local ok, result = dragon.res.load("example/loadgameobject:gameobject")
    if ok then
        go = result:GetFromPool()
    end
    go.transform:SetParent(self.gameobject.transform, false)
    go:ReturnToPool()
    log.debug("load_gameobject成功")
end

--- 加载element
function M:load_element()
    local element = require "dragon.ui.element"
    local e = element.new()
    e.res = "example/loadelement:elementgameobject"
    e:load()
    e:set_parent(self.gameobject.transform, false)
    log.debug("load_element成功")
end

--- 字典测试
function M:dic_test()
    local dict = require "dragon.collection.dict"
    local dic = dict()
    dic.count = 1
    log.debug("dic.count = "..dic.count)
    dic.set("key_1","value_1")
    log.debug("dic.count = "..dic.count)
end

--- store测试
function M:store_test()
    local state = 
    {
        info = {
            name = {
                value = "名字"
            }
        }
    }
    local a = "空字段"
    
    print(state["info"])
    
    state.info.name.value = "被改变以后的名字"
end

--- 事件测试
function M:event_test()
    local event_func = function(args)
        log.debug("这是一个事件测试: "..args)
    end
    local event_1 = dragon.event("event_1")
    event_1.on(event_func)
    event_1("event_1")
    
    dragon.event.on("event_2", event_func)
    dragon.event.emit("event_2", "event_2")
end

--- LuaEnv释放测试
function M:unload_env_test()
    local func = function()
        print("Start生命周期触发成功")
    end
    dragon.monoevent.on(nil, "Start", func)
    dragon.timer.start(function() dragon.unload() end, 5, 1)
    dragon.xlua.util.print_func_ref_by_csharp()
end

return M
