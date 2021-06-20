local dragon = require "dragon"
local log = dragon.logging.get("example-store")

local M = {}

M.state = function()
    return 
    {
        msg = "消息"
    }
end

M.getters = {
    get_msg = function(state)
        return function(args)
           return  state.msg
        end
    end
}

M.actions = {
    print = function(store, state, args)
        log.debug("action调用成功 "..args)
        store.mutation_test(args)
    end
}

M.mutations = {
    mutation_test = function(store, state,args)
        log.debug("mutation调用成功 "..args)
        store.emit("打印事件测试", args)
    end
}

return M