# lunash

`bash-like`的shell，但是使用lua语法和函数代理式的二进制调用

*只是玩具，请不要在生产环境使用*  

## 基本目标

目前一切都停留在非常早期的构想阶段，我暂时准备把目标平台限定为带`lua >= 5.3`环境的常见Linux系统

*探索lua究竟能有多灵活!*  

``` lua
-- 函数代理式的二进制调用
mkdir "dir_1"
grep("pattern", "a.txt")

-- 原生lua控制流与内置库
for line in _lua.io.lines("example.txt") do
    print(line)
end

-- bash-like的环境变量管理
export("proxy","http://localhost:8080")

-- 或者更lua风格一点
_env["proxy"] = "http://localhost:8080"

-- alias准备直接用lua function替代
function gcl(...)
    git("clone", "--recurse-submodules", ...)
end
```
