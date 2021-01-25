local _M = {}

--- Try to load a module.
-- Will not throw an error if the module was not found, but will throw an error if the
-- loading failed for another reason (eg: syntax error).
-- @param module_name Path of the module to load (ex: kong.plugins.keyauth.api).
-- @return success A boolean indicating wether the module was found.
-- @return module The retrieved module.
function _M.load_module_if_exists( module_name )
    local status, res = pcall(require, module_name)
    if status then
        return true, res
    elseif type(res) == "string" and string.find(res, "module '" .. module_name .. "' not found", nil, true) then
        return false
    else
        error(res)
    end
end

function _M.dyups_name(service_name)
    return "apis." .. service_name .. ".upstream"
end

return _M