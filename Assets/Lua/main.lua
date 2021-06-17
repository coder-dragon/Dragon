local dragon = require "dragon"
local demo = require "ui.examples.demo"
print("游戏入口函数")
print("先尝试注入gameobject对象")
local UE = CS.UnityEngine
local gameobject = UE.GameObject.Find("Demo")
local lua_injecttion = gameobject:GetComponent(typeof(CS.Dragon.LuaExtensions.LuaInjection))
lua_injecttion:Inject(demo)
print("注入gameobject对象成功")

demo:store_test()