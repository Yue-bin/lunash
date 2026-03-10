--- 环境变量和相关操作
--- TODO: 直接使用environ，而不是自己维护一份
--- @class env
local _M = {}

local stdlib = require("posix.stdlib")

--- @alias env_key string
--- @alias env_value string

--- 全局环境，用于存放环境变量
--- @type {env_key:env_value}
_M._env = {}

--- 从系统环境变量中导入环境变量
function _M:init()
    local env = stdlib.getenv()
    for k, v in pairs(env) do
        self._env[k] = v
    end
end

--- 获取环境变量
--- @param name string
--- @return env_value
function _M:get(name)
    return self._env[name] or ""
end

--- string[]与posix的:分割的环境变量互转

--- posix的:分割的环境变量转string[]
--- @param posix_env string
--- @return string[]
function _M:from_posix(posix_env)
    local env_val_list = {}
    for env_val in string.gmatch(posix_env, "[^:]+") do
        table.insert(env_val_list, env_val)
    end
    return env_val_list
end

--- string[]转posix的:分割的环境变量
--- @param env_val_list string[]
--- @return string
function _M:to_posix(env_val_list)
    return table.concat(env_val_list, ":")
end

return _M
