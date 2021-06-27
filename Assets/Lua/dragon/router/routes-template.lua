--[[
    路由表定义模板
]]

local dragon = require "dragon"

-- 一个空的界面实例定义
local empty_activity
local empty = function()
    if not empty_activity then
        empty_activity = dragon.ui.element()
    end
    return empty_activity
end

local M = {
    -- ui界面层级分类
    -- layer ui层级
    -- keep 当下一路由未覆盖此层级定义时，是否保持一直打开状态
    layout = {
        background = {layer = 0, keep = true},  -- 背景板
        default = {layer = 100, keep = true},   -- 默认ui界面
        popup = {layer = 200},                  -- 弹出窗口
        float = {layer = 600, keep = true},     -- 浮动界面
        top = {layer = 800, keep = true},       -- 最上级界面
    },
    
    routes = {
        path = "/main-path/child-path?param1=value", -- 路由路径: "/{主路由}/{子路由}?{参数1}=value"
        name = "blank", -- 命名路由
        redirect = "redirect" or function(to, from, next)  end, -- 路由重定向路径or重定向方法
        before_enter = function(to, from, next)  end, -- 路由 before_enter 守卫
        compoents = { -- 路由子组件定义，对应每个界面实例
            background = empty, 
            default = empty,
            popup = empty,
            float = empty,
            top = empty,
        },
        children = {}, -- 嵌套路由
        meta = {}, -- 元数据
    }
}