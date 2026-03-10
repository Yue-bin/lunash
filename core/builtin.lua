--- 内置命令
--- TODO: 添加更多
--- @class builtin
local _M = {}

local utils = require("core.utils")
local _env = require("core.env")._env

--- 导出环境变量
--- @param name string
--- @param value string
function _M.export(name, value)
    _env[name] = value
end

return utils.readonly(_M)
