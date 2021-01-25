local _M = {}
local _mt = { __index = _M }

function _M.ok(data)
    return setmetatable({
        code = "0000",
        message = "ok",
        data = data
    }, _mt)
end

function _M.illegal_argument_error(argument_name)
    return setmetatable({
        code = "1010",
        message = "The request argument named '" .. (argument_name or '') .. "' was illegal.please check",
    }, _mt)
end

return _M