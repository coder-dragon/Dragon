local dragon = require "dragon"

print("游戏入口函数")

print("先尝试注入gameobject对象")
local ue = CS.UnityEngine
local gameobject = ue.GameObject.Find("GameObject")
local lua_injecttion = gameobject:GetComponent(typeof(CS.Dragon.LuaExtensions.LuaInjection))

local test = require "ui.examples.test"
lua_injecttion:Inject(test)

dragon.coroutine.start(test.load_gameobject, test)

local log = dragon.logging.get("element")
log.debug(11111111111111)

