--[[
    路由表定义模板
]]

local dragon = require "dragon"

local empty_activity

--- 一个空的界面实例定义
local empty = function()
    if not empty_activity then
        empty_activity = dragon.ui.activity()
    end
    return empty_activity
end

local M = {
    -- ui界面层级分类
    -- layer OrderLayer层级
    -- keep 当下一路由未覆盖此层级定义时，是否保持一直打开状态
    layout = {
        background = {layer = 0, keep = true},  -- 背景板
        default = {layer = 100, keep = true},   -- 默认ui界面
        popup = {layer = 200},                  -- 弹出窗口
        float = {layer = 600, keep = true},     -- 浮动界面
        top = {layer = 800, keep = true},       -- 最上级界面
    },

    routes = {
        path = "/main",
        compoents = {
            default = function()
                return require "ui.main.main"
            end
        }
    }
}