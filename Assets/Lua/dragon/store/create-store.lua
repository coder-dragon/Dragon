local dragon = require "dragon"
local promise = dragon.promise
local weak_mt = {__mode = "k"}
local log = dragon.logging.get("store")

return function(options)
    assert(name, "store should have a name.")
    local state = type(options.state) == "function" and options.state() or options.state or {}
    local store = {
        name = options.name,
        __options = options,
        __subscribers = {}, -- <name, {receiver1 = true, recceiver2 = true}>
    }
end