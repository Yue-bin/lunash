--- 文件相关的工具
--- @class utils.file
local _M = {}

local env = require("core.env")
local unistd = require("posix.unistd")
local stat = require("posix.sys.stat")

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
