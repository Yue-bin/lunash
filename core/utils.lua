--- 常用工具
--- @class utils
local _M = {}
local base = _G
local env = require("core.env")
local unistd = require("posix.unistd")
local stat = require("posix.sys.stat")

--- 用于写入一个表的元表的某个项而不影响原有元表
--- @param table table
--- @param key any
--- @param value any
--- @return table
function _M.setmt(table, key, value)
    local mt = base.getmetatable(table)
    if mt then
        mt[key] = value
        base.setmetatable(table, mt)
    else
        base.setmetatable(table, { [key] = value })
    end
    return table
end

--- 用于支持多个__index元表堆叠形成的环境

--- 自动将env在排除冲突的情况下设为table的最外层__index元表
--- @param table table
--- @param env table
--- @return table
function _M.add_env_outside(table, env)
    local mt = base.getmetatable(table)
    if mt and mt.__index then
        _M.add_env_outside(mt.__index, env)
    else
        _M.setmt(table, "__index", env)
    end
    return table
end

--- 自动将env在排除冲突的情况下设为table的最内层__index元表
--- @param table table
--- @param env table
--- @return table
function _M.add_env_inside(table, env)
    local mt = base.getmetatable(table)
    if mt and mt.__index then
        -- 把原有的__index元表堆叠到env的最外层
        _M.add_env_outside(mt.__index, env)
        _M.setmt(table, "__index", mt)
    else
        _M.setmt(table, "__index", env)
    end
    return table
end

--- 用于创造一个表的只读代理
--- @param table table
--- @return table
function _M.readonly(table)
    return base.setmetatable({}, {
        __index = table,
        __newindex = function(_, _, _)
            base.error("Don`t touch me here...")
        end,
        __len = function()
            return #table
        end,
        -- __metatable = false
    })
end

--- 用于判断表是否包含某个值
--- @param t table
--- @param val any
--- @return boolean
function _M.table_has_val(t, val)
    for _, v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

--- 用于判断表是否包含某个键
--- @param t table
--- @param key any
--- @return boolean
function _M.table_has_key(t, key)
    if t[key] then
        return true
    end
    return false
end

--- 判断路径是否为常规文件(跟随软链接)
--- @param path string
--- @return boolean
function _M.is_regfile(path)
    local path_stat = stat.stat(path)
    return path_stat
        and stat.S_ISREG(path_stat.st_mode) ~= 0
        or false
end

--- 从传入的paths或者PATH中查找可执行文件，返回第一个找到的路径
--- @param exec_name string
--- @param paths string[]?
--- @return string?
function _M.find_executable(exec_name, paths)
    -- 处理绝对路径和多级相对路径exec_name的情况
    -- /usr/bin/ls
    -- bin/ls
    -- ./ls
    if exec_name:find("/") then
        if unistd.access(exec_name, 'x') and _M.is_regfile(exec_name) then
            return exec_name
        end
        return nil
    end

    -- 一级相对路径
    paths = paths or env.from_posix(env.get("PATH"))
    for _, path in ipairs(paths) do
        local exec_path = path .. "/" .. exec_name
        if unistd.access(exec_path, 'x') and _M.is_regfile(exec_path) then
            return exec_path
        end
    end
    return nil
end

return _M
