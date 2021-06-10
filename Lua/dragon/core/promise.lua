local PENDING = "pending"
local FULFILLED = "fulfilled" 
local REJECTED = "rejected"

local M = {}
local promise = 
{
    __typename  = "promise",
    status      = PENDING,
    value       = nil,
    resolved    = nil,
    reason      = nil,
    on_resolves = {},
    on_rejects  = {}
}

promise.__index = promise

function promise:next(on_resolve, on_reject)
    
end

function M.new(executor)
    local self = setmetatable({}, promise)
    return self
end

function M.resolve(value)
    return M.new(function(resolve, reject)
        resolve(value)
    end)
end

function M.reject(value)
    return M.new(function(resolve, reject)
        reject(value)
    end)
end

function M.is_promise(value)
    if type(value) ~= "table" then
        return false
    end
    return value.__typename == "promise"
end

function M.wait_for_seconds(app, seconds)
    return M.new(function(resolve, reject)
        app.coroutine.start(function()
            app.coroutine.wait(seconds)
            resolve()
        end)
    end)
end
