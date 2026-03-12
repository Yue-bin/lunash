--- string相关的工具
--- @class utils.strings
local _M = {}

--- 按照sep将string分割成string[]
--- @param str string
--- @param sep string 注意只在sep为char时才有效
--- @return string[]
function _M.split(str, sep)
    local items = {}
    for item in string.gmatch(str, "[^" .. sep .. "]+") do
        table.insert(items, item)
    end
    return items
end

return _M
