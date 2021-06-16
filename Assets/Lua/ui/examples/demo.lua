local dragon = require "dragon"
local log = dragon.logging.get("demo")
local M = {}

function M:log_test()
    log.debug("日志模块测试成功")
end

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

function M:load_element()
    local element = require "dragon.ui.element"
    local e = element.new()
    e.res = "example/loadelement:elementgameobject"
    e:load()
    e:set_parent(self.gameobject.transform, false)
    log.debug("load_element成功")
end

function M:dic_test()
    local dict = require "dragon.collection.dict"
    local dic = dict()
    dic.count = 1
    log.debug("dic.count = "..dic.count)
    dic.set("key_1","value_1")
    log.debug("dic.count = "..dic.count)
end

return M