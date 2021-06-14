local dragon = require "dragon"
local GameObjectPool = CS.Dragon.Pooling.GameObjectPool
local M = {}

function M:print_name()
    print(self.GameObject.name)
end

function M:load_gameobject()
    local gameobject
    local ok, result = dragon.res.load("example:gameobject")
    if ok then
        local pool = GameObjectPool(1,result,self.GameObject.transform)
        gameobject = pool.Get()
    end
    gameobject.transform:SetParent(self.GameObject.transform, false)
end

return M
