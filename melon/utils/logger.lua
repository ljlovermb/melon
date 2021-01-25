local _M = {}                            -- 局部的变量
_M._VERSION = '1.0'                      -- 模块版本

local mt = { __index = _M }

local function get_logger_handle(logger_path)
    local handler, err = {}, "Failed to open the log file. please check the following tips:"

    local suffix = string.sub(logger_path, #logger_path)
    if suffix ~= '/' then
        logger_path = logger_path .. '/'
    end

    handler["debug"], _ = io.open(logger_path .. "info.log", "a+")
    if not handler["debug"] then
        err = err .. _
        return nil, err
    end

    handler["info"], _ = io.open(logger_path .. "info.log", "a+")
    if not handler["info"] then
        err = err .. _
        return nil, err
    end

    handler["warn"], _ = io.open(logger_path .. "info.log", "a+")
    if not handler["warn"] then
        err = err .. _
        return nil, err
    end

    handler["error"], _ = io.open(logger_path .. "error.log", "a+")
    if not handler["error"] then
        err = err .. _
        return nil, err
    end

    return handler, nil
end

local function get_logger_level(level_sets)
    local level, err = nil, nil
    if not level_sets then
        err = "Failed to initialize the logger,please sets log level in the 'melon.ini' file."
        return level, err
    end

    if string.lower(level_sets) == 'debug' then
        level = 4
    elseif string.lower(level_sets) == 'info' then
        level = 3
    elseif string.lower(level_sets) == 'warn' then
        level = 2
    elseif string.lower(level_sets) == 'error' then
        level = 1
    else
        err = 'Invalid logger level. please check.'
    end

    return level, err
end

function _M:debug(format, ...)
    if self.level < 4 then
        return
    end

    local v = { ... }
    if format and next(v) then
        print(os.date("%Y-%m-%d %H:%M:%S") .. self.colors.white(" [DEBUG] ") .. "- ["
                .. self.filename .. "]: " .. string.format(format, ...))
    end

    self.handler["debug"]:write(os.date("%Y-%m-%d %H:%M:%S") .. self.colors.white(" [DEBUG] ") .. "- ["
            .. self.filename .. "]: " .. string.format(format, ...) .. "\n")
    self.handler["debug"]:flush()
end

function _M:info(format, ...)
    if self.level < 3 then
        return
    end

    local v = { ... }
    if format and next(v) then
        print(os.date("%Y-%m-%d %H:%M:%S") .. self.colors.blue(" [INFO] ") .. "- ["
                .. self.filename .. "]: " .. string.format(format, ...))
    end

    self.handler["info"]:write(os.date("%Y-%m-%d %H:%M:%S") .. self.colors.blue(" [INFO] ") .. "- ["
            .. self.filename .. "]: " .. string.format(format, ...) .. "\n")
    self.handler["info"]:flush()
end

function _M:warn(format, ...)
    if self.level < 2 then
        return
    end

    local v = { ... }
    if format and next(v) then
        print(os.date("%Y-%m-%d %H:%M:%S") .. self.colors.yellow(" [WARN] ") .. "- ["
                .. self.filename .. "]: " .. string.format(format, ...))
    end

    self.handler["warn"]:write(os.date("%Y-%m-%d %H:%M:%S") .. self.colors.yellow(" [WARN] ") .. "- ["
            .. self.filename .. "]: " .. string.format(format, ...) .. "\n")
    self.handler["warn"]:flush()
end

function _M:error(format, ...)
    if self.level < 1 then
        return
    end

    local v = { ... }
    if format and next(v) then
        print(os.date("%Y-%m-%d %H:%M:%S") .. self.colors.red(" [ERROR] ") .. "- ["
                .. self.filename .. "]: " .. string.format(format, ...))
    end

    self.handler["error"]:write(os.date("%Y-%m-%d %H:%M:%S") .. self.colors.red(" [ERROR] ") .. "- ["
            .. self.filename .. "]: " .. string.format(format, ...) .. "\n")
    self.handler["error"]:flush()
    self.handler["info"]:write(os.date("%Y-%m-%d %H:%M:%S") .. self.colors.red(" [ERROR] ") .. "- ["
            .. self.filename .. "]: " .. string.format(format, ...) .. "\n")
    self.handler["info"]:flush()
end

function _M:get_logger(filename, context)
    local handler, err = get_logger_handle(context.log_path)
    if not handler then
        return nil, err
    end

    local level, err = get_logger_level(context.log_level)
    if not level then
        return nil, err
    end

    local ansicolors = require("melon.libs.ansicolors")
    local colors = {}
    for _, v in ipairs({ "red", "green", "yellow", "blue", "white", "cyan", "magenta" }) do
        colors[v] = function(str)
            return ansicolors("%{" .. v .. "}" .. str .. "%{reset}")
        end
    end

    return setmetatable(
            { filename = filename,
              handler = handler,
              level = level,
              colors = colors
            }, mt), err
end

return _M