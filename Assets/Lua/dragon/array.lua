local insert = table.insert
local M = {}

-- 将多个数组合并成一个数组
function M.concat(...)
    local ret = {}
    local args = table.pack(...)
    for _, arr in ipairs(args) do
        for _, item in ipairs(arr) do
            insert(ret, item)
        end
    end
    return ret
end

-- 将一个元素合并到一个数组末尾，作为新数组返回
function M.concat_one(tbl, item)
    local ret = {}
    for _, v in ipairs(tbl) do
        insert(ret, v)
    end
    insert(ret, item)
    return ret
end

-- 接收一个函数作为累加器，数组中的每个值（从左到右）开始缩减，最终计算为一个值
-- callback_fn = function(previous_value, current_value, current_index, array)
function M.reduce(tbl, callback_fn, initial_value)
    local previous_value = initial_value
    for current_index, current in ipairs(tbl) do
        previous_value = callback_fn(previous_value, current, current_index, tbl)
    end
    return previous_value
end

-- 从数组切分出一个新数组
-- first 起始位置（包含）
-- last 结束位置（包含），若last小于0，则表示从末尾开始计算位置
-- 例：slice(2,-2) 表示仅获取除首部尾部两个元素外的数组
function M.slice(tbl, first, last)
    first = first or 1
    last = last or #tbl
    if last < 0 then
        last = #tbl + last + 1
    end

    local sliced = {}
    for i = first, last do
      sliced[#sliced+1] = tbl[i]
    end
    return sliced
end

-- 把数组的第一个元素从其中删除，并返回第一个元素的值
function M.shift(tbl)
    local ret = tbl[1]
    table.remove(tbl, 1)
    return ret
end

-- 翻转数组，会修改原数组
function M.reverse(tbl)
    assert(tbl)
    for i=1,math.floor(#tbl/2) do
        tbl[i], tbl[#tbl-i+1] = tbl[#tbl-i+1], tbl[i]
    end
    return tbl
end

-- 对数组内每个元素进行callback，并用返回值组合成一个新的数组
function M.map(tbl, callback)
    local ret = {}
    for k, v in pairs(tbl) do
        ret[k] = callback(v)
    end
    return ret
end

-- 查询目标在数组中的位置
-- 若目标不存在则返回-1
function M.index_of(tbl, target)
    for i,v in ipairs(tbl) do
        if v == target then
            return i
        end
    end
    return -1
end

-- 清空数组
function M.clear(tbl)
    for k,_ in pairs(tbl) do
        tbl[k] = nil
    end
end

-- 检测数组中的元素是否满足指定条件，只要有任意元素满足就返回真
function M.any(tbl, predicate)
    for i, v in ipairs(tbl) do
        if predicate(v) then
            return true
        end
    end
end

-- 对数组内每个元素按predicate进行过滤，返回一个新数组
function M.filter(tbl, predicate)
    local ret = {}
    for _, v in ipairs(tbl) do
        if predicate(v) then
            table.insert(ret, v)
        end
    end
    return ret
end

-- 将另外一个数组追加到目标数组中
function M.append(tbl, other)
    for i, v in ipairs(other) do
        insert(tbl, v)
    end
end

-- 移除数组中所有满足条件的元素
function M.remove(tbl, predicate)
    assert(predicate)
    local ret = {}
    local i = 1
    while i <= #tbl do
        if predicate(tbl[i]) then
            table.remove(tbl, i)
        else
            i = i + 1
        end
    end
end

-- 检测指定表是否为数组
function M.is_array(tbl)
    if not tbl or type(tbl) ~= "table" then
        return false
    end
    local mt = getmetatable(tbl)
    if mt then
        return false
    end
    return true
end

return M