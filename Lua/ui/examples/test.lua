local dragon = require "dragon"
local M = {}

function M:print_name()
    print(self.GameObject.name)
end

function M:load_gameobject()
    local gameobject
    local ok, result = dragon.res.load("example:gameobject")
    if ok then
        gameobject = CS.UnityEngine.GameObject.Instantiate(result)
    end
    gameobject.transform:SetParent(self.GameObject.transform, false)
end

return M
