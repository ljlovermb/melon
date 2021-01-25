local base_plugins = require("melon.plugins.base_handler")
local sign_auth_handler = base_plugins:extend()
local logger_factory = require("melon.utils.logger")
local logger = logger_factory:get_logger("sign_auth.lua", context)

sign_auth_handler.PRIORITY = 0
sign_auth_handler.DELAY = 5

function sign_auth_handler:new()
    sign_auth_handler.super.new(self, 'sign_auth_plugin')
end

function sign_auth_handler:timed_task()
    --logger:info("Attempt to execute the timed task of plugin : %s",sign_auth_handler:get_name())
end

return sign_auth_handler