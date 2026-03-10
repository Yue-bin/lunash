--- 可执行文件调用的包装器
--- TODO: 没有alias将出现层级缺失，alias本身似乎是用于提供优先于builtin的层级的
--- executable -> function
---
--- 可执行的查找顺序参照bash
--- 1. alias
--- 2. builtin
--- 3. function
--- 4. executable in PATH
---
--- 不过由于我们没有alias，所以变成下面这样
---
--- 1. builtin
--- 2. function
--- 3. executable in PATH
--- @class wrap.cmd
local _M = {}

local unistd = require("posix.unistd")
local utils = require("core.utils")
local builtin = require("core.builtin")
local user_env = require("core.wrap.user_env")

--- 自下而上地构建调用环境
user_env = utils.setmt(
    user_env,
    "__index",
    --- wrapper func
    --- 返回包装成函数的可执行调用
    --- @param key string
    --- @return function
    function(_, key)
        --- 可执行调用
        --- @param ... any
        return function(...)
            unistd.exec(key, ...)
        end
    end
)

--- TODO: 这里最终传出的是builtin，但应该传出的是user_env，这样user才能在正确的层级创建function
_M = utils.add_env_outside(builtin, user_env)

return _M
