local promise = require "dragon.core.promise"

local p = promise.new(function(resolve, reject)
    reject("成功结果")
end)

p:next(10):next(function(e)
    print(e..1)
end):catch(function(e)
    print(e..3)
end)

p.next(function( ... )
    -- body
end,function( ... )
    print(e..4)
end)