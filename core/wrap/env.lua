--- 环境变量和相关操作
--- TODO: 直接使用environ，而不是自己维护一份
--- @class env
local _M = {}

local strings = require("core.utils.strings")
local stdlib = require("posix.stdlib")

--- @alias env_key string
--- @alias env_value string?

--- 获取环境变量
--- @param key env_key
--- @return env_value
function _M.get(key)
    -- 防止传入nil之后回传所有的env
    -- getenv在键不存在的情况下返回nil
    if key == nil then
        return nil
    end
    return stdlib.getenv(key)
end

--- 设置环境变量
--- @param key env_key
--- @param value env_value
function _M.set(key, value)
    -- value 为nil则删除，符合直觉
    stdlib.setenv(key, value)
end

--- 全局环境，用于代理到环境变量的修改
--- @type {env_key:env_value}
_M.proxy = setmetatable({}, {
    --- 代理写
    --- @param key env_key
    --- @param value env_value
    __newindex = function(_, key, value)
        _M.set(key, value)
    end,
    --- 代理读
    --- @param key env_key
    --- @return env_value
    __index = function(_, key)
        return _M.get(key)
    end
})

--- string[]与posix的:分割的环境变量互转

--- posix的:分割的环境变量转string[]
--- @param posix_env string
--- @return string[]
function _M:from_posix(posix_env)
    return strings.split(posix_env, ":")
end

--- string[]转posix的:分割的环境变量
--- @param env_val_list string[]
--- @return string
function _M:to_posix(env_val_list)
    return table.concat(env_val_list, ":")
end

return _M
