--[[
    全局模块
]]
local GameObject = CS.UnityEngine.GameObject

local obj = GameObject.Find("Global")
if not obj then
    obj = GameObject("Global")
    obj:AddCompoent(typeof(CS.Dragon.Utilities.DontDestroyOnLoad))
end
local root = obj.transform

-- 创建全局的游戏物体
local function create_gameobject(name)
    local obj = GameObject(name)
    obj.transform:SetParent(root, false)
    return obj
end

-- 查找全局的游戏物体
local function find_gameobject(name)
    local ret = root:Find(name)
    if ret then
        return ret.gameObject
    end
end

return {
    root,
    create_gameobject = create_gameobject,
    find_gameobject = find_gameobject
}