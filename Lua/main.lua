print("游戏入口函数")

print("先尝试注入gameobject对象")
local ue = CS.UnityEngine
local gameobject = ue.GameObject.Find("gameObject")
local lua_injecttion = gameobject:GetComponent(typeof(CS.Dragon.LuaExtensions.LuaInjection))

local test = require "ui.examples.test"
lua_injecttion:Inject(test)

test:print_name()