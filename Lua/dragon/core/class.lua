local classes = {} -- <class_type,fields>

local function class(base)
    local class_type = {
        __type = 'class',
        ctor = false,
    }
      
    local vtbl = {}  
    classes[class_type] = vtbl  
    setmetatable(class_type, { __newindex = vtbl, __index = vtbl })
  
    if base then
        setmetatable(vtbl, { __index = function(t, k)
                local ret = classes[base][k]  
                vtbl[k] = ret  
                return ret  
            end  
        })  
    end  
      
    class_type.__base = base  
    class_type.new = function(...)  
        local obj = {}
        obj.__base  = class_type
        obj.__type  = 'object'
        obj.__class = class_type -- 另外缓存一个变量，避免在super中__base会被临时修改
        do  
            local create  
            create = function(c, ...)  
                if c.__base then  
                    create(c.__base, ...)  
                end  
                if c.ctor then  
                    c.ctor(obj, ...)  
                end  
            end  
  
            create(class_type,...)  
        end  
  
        local mt = { __index = classes[class_type] }
        if class_type.overridemetatable then
            class_type.overridemetatable(obj, mt)
        else
            setmetatable(obj, mt)
        end
        return obj
    end  
  
    class_type.super = function(self, f, ...)  
        assert(self and self.__type == 'object', string.format("'self' must be a object when call super(self, '%s', ...)", tostring(f)))  
  
        local origin_base = self.__base  
        -- find the first f function that differ from self[f] in the inheritance chain
        local s = self  
        local base = s.__base  
        while base and s[f] == base[f] do  
            s = base  
            base = base.__base  
        end  
          
        assert(base and base[f], string.format("base class or function cannot be found when call .super(self, '%s', ...)", tostring(f)))  
        --now base[f] is differ from self[f], but f in base also maybe inherited from base's baseClass  
        while base.__base and base[f] == base.__base[f] do  
            base = base.__base  
        end  
  
        -- If the base also has a baseclass, temporarily set :super to call that baseClass' methods  
        -- this is to avoid stack overflow  
        if base.__base then  
            self.__base = base  
        end  
  
        --now, call the super function  
        local result = base[f](self, ...)  
  
        --set back  
        if base.__base then  
            self.__base = origin_base  
        end  
  
        return result  
    end  
  
    return class_type  
end

return class