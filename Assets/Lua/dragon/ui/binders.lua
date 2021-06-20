--[[
    组件事件绑定
    重定义路径：dragon.config.binders
]]
local dragon = require "dragon"

local M = {
    ["obj.text"] = function(obj, state, name)
        local bind_text = function()
            obj.text = state[name]
        end
        state.__binders[name] = bind_text
        return function()
            state.__binders[name] = nil
        end
    end,
    ["gameobject.element"] = function(element, ref, child_element)
        child_element:set_gameobject(ref, true)
        return function()
            child_element:release()
        end
    end,
    ["gameobject.click"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        local trigger = CS.Dragon.MonoEventListeners.EventTriggerListener.Get(ref)
        trigger.PointerClick:AddListener(handler)
        return function()
            trigger.PointerClick:RemoveListener(handler)
        end
    end,
    ["gameobject.enable"] = function(element, ref, func)
        local handler = function() func(element) end
        dragon.monoevent.on(ref, "OnEnable", handler)
        return function()
            dragon.monoevent.off(ref, "OnEnable", handler)
        end
    end,
    ["gameobject.update"] = function(element, ref, func)
        local handler = function() func(element) end
        dragon.monoevent.on(ref, "Update", handler)
        return function()
            dragon.monoevent.off(ref, "Update", handler)
        end
    end,
    ["gameobject.lateupdate"] = function(element, ref, func)
        local handler = function() func(element) end
        dragon.monoevent.on(ref, "LateUpdate", handler)
        return function()
            dragon.monoevent.off(ref, "LateUpdate", handler)
        end
    end,
    ["gameobject.mousedown"] = function(element, ref, func)
        local handler = function() func(element) end
        dragon.monoevent.on(ref, "OnMouseDown", handler)
        return function()
            dragon.monoevent.off(ref, "OnMouseDown", handler)
        end
    end,
    ["gameobject.dimensions"] = function(element, ref, func)
        local handler = function() func(element, ref) end
        local listener = CS.Dragon.MonoEventListeners.MonoEventListenersBehaviourEventListener.Get(ref)
        listener.DimensionsChanged:AddListener(handler)
        return function()
            listener.DimensionsChanged:RemoveListener(handler)
        end
    end,
    ["gameobject.drag"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        local trigger = CS.Dragon.MonoEventListeners.EventTriggerListener.Get(ref)
        trigger.Drag:AddListener(handler)
        return function()
            trigger.Drag:RemoveListener(handler)
        end
    end,
    ["gameobject.scroll"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        local trigger = CS.Dragon.MonoEventListeners.EventTriggerListener.Get(ref)
        trigger.Scroll:AddListener(handler)
        return function()
            trigger.Scroll:RemoveListener(handler)
        end
    end,
    ["scrollrect.value"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.onValueChanged:AddListener(handler)
        return function()
            ref.onValueChanged:RemoveListener(handler)
        end
    end,
    ["scrollbar.value"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.onValueChanged:AddListener(handler)
        return function()
            ref.onValueChanged:RemoveListener(handler)
        end
    end,
    ["toggle.value"] = function(element, ref, func)
        local handler = function() func(element, ref.isOn) end
        ref.onValueChanged:AddListener(handler)
        return function()
            ref.onValueChanged:RemoveListener(handler)
        end
    end,
    ["inputfield.value"] = function(element, ref, func)
        local handler = function() func(element) end
        ref.onValueChanged:AddListener(handler)
        return function()
            ref.onValueChanged:RemoveListener(handler)
        end
    end,
    ["inputfield.submit"] = function(element, ref, func)
        local handler = function() func(element) end
        ref.onEndEdit:AddListener(handler)
        return function()
            ref.onEndEdit:RemoveListener(handler)
        end
    end,
    ["inputfield.select"] = function(element, ref, func)
        local handler = function() func(element) end
        ref.onSelect:AddListener(handler)
        return function()
            ref.onSelect:RemoveListener(handler)
        end
    end,
    ["inputfield.deselect"] = function(element, ref, func)
        local handler = function() func(element) end
        ref.onDeselect:AddListener(handler)
        return function()
            ref.onDeselect:RemoveListener(handler)
        end
    end,
    ["button.click"] = function(element, ref, func, options)
        local handler = function()
            func(element)
        end
        ref.onClick:AddListener(handler)
        return function()
            ref.onClick:RemoveListener(handler)
        end
    end,
    ["slider.value"] = function(element, ref, func)
        local handler = function() func(element) end
        ref.onValueChanged:AddListener(handler)
        return function()
            ref.onValueChanged:RemoveListener(handler)
        end
    end,
    ["dropdown.value"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.onValueChanged:AddListener(handler)
        return function()
            ref.onValueChanged:RemoveListener(handler)
        end
    end,
    ["trigger.click"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.PointerClick:AddListener(function(e) func(element, e) end)
        return function()
            ref.PointerClick:RemoveListener(handler)
        end
    end,
    ["trigger.down"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.PointerDown:AddListener(function(e) func(element, e) end)
        return function()
            ref.PointerDown:RemoveListener(handler)
        end
    end,
    ["trigger.enter"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.PointerEnter:AddListener(function(e) func(element, e) end)
        return function()
            ref.PointerEnter:RemoveListener(handler)
        end
    end,
    ["trigger.exit"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.PointerExit:AddListener(function(e) func(element, e) end)
        return function()
            ref.PointerExit:RemoveListener(handler)
        end
    end,
    ["trigger.up"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.PointerUp:AddListener(function(e) func(element, e) end)
        return function()
            ref.PointerUp:RemoveListener(handler)
        end
    end,
    ["trigger.move"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.Move:AddListener(function(e) func(element, e) end)
        return function()
            ref.Move:RemoveListener(handler)
        end
    end,
    ["trigger.drag"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.Drag:AddListener(function(e) func(element, e) end)
        return function()
            ref.Drag:RemoveListener(handler)
        end
    end,
    ["trigger.enddrag"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.EndDrag:AddListener(function(e) func(element, e) end)
        return function()
            ref.EndDrag:RemoveListener(handler)
        end
    end,
    ["trigger.begindrag"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.BeginDrag:AddListener(function(e) func(element, e) end)
        return function()
            ref.BeginDrag:RemoveListener(handler)
        end
    end,
    ["trigger.drop"] = function(element, ref, func)
        local handler = function(e) func(element, e) end
        ref.Drop:AddListener(function(e) func(element, e) end)
        return function()
            ref.Drop:RemoveListener(handler)
        end
    end,
    ["app.event"] = function(element, event_name, func)
        local handler = function(e) func(element, e) end
        element.app.event.on(event_name, handler)
        return function()
            element.app.event.off(event_name, handler)
        end
    end
}

return M