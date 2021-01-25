local result_type = require("melon.utils.result.result_type")
local json = require("cjson")

local _M = {}
_M.HTTP_MELON_ERROR = 450

function _M.ok(data)
    return ngx.say(json.encode(result_type.ok(data)))
end

function _M.illegal_argument(arg_name)
    return ngx.say(json.encode(result_type.illegal_argument_error(arg_name)))
end

return _M