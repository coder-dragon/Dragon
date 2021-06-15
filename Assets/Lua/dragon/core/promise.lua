--[[
    promise对象
    代码逻辑执行报错也算reject
]]

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

local promise_resolve
local promise_reject

promise_resolve = function (self, value)
    if M.is_promise(value) then
        value:next(function(ret) promise_resolve(self, ret) end, function(err) promise_reject(self, err) end)
    else
        if self.status == PENDING then
            self.status = FULFILLED
            self.value = value
            self.resolved = value
            for index, resolve in ipairs(self.on_resolves) do
                resolve(value)
            end
        end
    end
end

promise_reject = function (self, reason)
    if self.status == PENDING then
        self.status = REJECTED
        self.value = reason
        self.reason = reason
        for index, reject in ipairs(self.on_resolves) do
            reject(reason)
        end
    end
end

function promise:next(on_resolve, on_reject)
    return M.new(function(resolve, reject)
        if type(on_resolve) ~= "function" then
            on_resolve = function(value) return value end
        end
        if self.status == FULFILLED then
            -- 代码报错强制执行失败，返回pcall结果
            local ok, result = pcall(on_resolve, self.value)
            if ok then
                resolve(result)
            else
                reject(result)
            end
        elseif self.status == REJECTED then
            if type(on_reject) ~= "function" then
                reject(self.reason)
            else
                -- 失败的回调里代码依然可能报错，代码报错则返回pcall结果
                local ok, result = pcall(on_reject, self.value)
                if ok then
                    reject(result)
                else
                    reject(result)
                end
            end
        elseif self.status == PENDING then
            table.insert(self.on_resolves, function(value)
                -- 代码报错强制执行失败，返回pcall结果
                local ok, result = pcall(on_resolve, self.value)
                if ok then
                    resolve(result)
                else
                    reject(result)
                end
            end)

            table.insert(self.on_rejects, function(value)
                -- 代码报错强制执行失败，返回pcall结果
                local ok, result = pcall(on_reject, self.value)
                if ok then
                    reject(result)
                else
                    reject(result)
                end
            end)
        end
    end)
end

function promise:catch(on_reject)
    return self:next(nil, on_reject)
end

function M.new(executor)
    local self = setmetatable({}, promise)
    local ok, result = pcall(executor, function(value)
        return promise_resolve(self, value)
    end,function(reason)
        return promise_reject(self, reason)
    end)
    -- 代码报错强制执行失败，返回pcall结果
    if not ok then
        promise_reject(self, result)
    end
    return self
end

-- 返回一个成功的promise
function M.resolve(value)
    return M.new(function(resolve, reject)
        resolve(value)
    end)
end

-- 返回一个失败的promise
function M.reject(value)
    return M.new(function(resolve, reject)
        reject(value)
    end)
end

-- 判断对象是否为promise
function M.is_promise(value)
    if type(value) ~= "table" then
        return false
    end
    return value.__typename == "promise"
end

-- 等待一定时间后成功
-- app      带协程字段的对象
-- seconds  等待的秒数
function M.wait_for_seconds(app, seconds)
    return M.new(function(resolve, reject)
        app.coroutine.start(function()
            app.coroutine.wait(seconds)
            resolve()
        end)
    end)
end

return M