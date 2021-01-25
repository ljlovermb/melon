---
-- from https://github.com/Mashape/kong/blob/master/kong/plugins/base_plugin.lua
-- modified by sumory.wu

local Object = require("melon.libs.classic")
local BasePlugin = Object:extend()
local logger = require("melon.utils.logger") :get_logger("base_handler.lua",context)

function BasePlugin:new(name)
    self._name = name
end

function BasePlugin:get_name(length)
    local plugin_name = self._name
    if not length or #plugin_name < length then
        return plugin_name
    end

    local initials = ''
    string.gsub(plugin_name,'[^_]+',function (w)
        initials = initials .. string.sub(w,0,1) .. '_'
    end)
    return string.sub(initials,0,#initials - 1)
end

function BasePlugin:init_worker()
    --ngx.log(ngx.DEBUG, " executing plugin \"", self._name, "\": init_worker")
    logger:debug("Executing plugin '%s' init_worker",self._name)
end

function BasePlugin:redirect()
    --ngx.log(ngx.DEBUG, " executing plugin \"", self._name, "\": redirect")
    logger:debug("Executing plugin '%s' redirect",self._name)
end

function BasePlugin:rewrite()
    --ngx.log(ngx.DEBUG, " executing plugin \"", self._name, "\": rewrite")
    logger:debug("Executing plugin '%s' rewrite",self._name)
end

function BasePlugin:access()
    --ngx.log(ngx.DEBUG, " executing plugin \"", self._name, "\": access")
    logger:debug("Executing plugin '%s' access",self._name)
end

function BasePlugin:balancer()
    --ngx.log(ngx.DEBUG, " executing plugin \"", self._name, "\": balancer")
    logger:debug("Executing plugin '%s' balancer",self._name)
end

function BasePlugin:header_filter()
    --ngx.log(ngx.DEBUG, " executing plugin \"", self._name, "\": header_filter")
    logger:debug("Executing plugin '%s' header_filter",self._name)
end

function BasePlugin:body_filter()
    --ngx.log(ngx.DEBUG, " executing plugin \"", self._name, "\": body_filter")
    logger:debug("Executing plugin '%s' body_filter",self._name)
end

function BasePlugin:log()
    --ngx.log(ngx.DEBUG, " executing plugin \"", self._name, "\": log")
    logger:debug("Executing plugin '%s' log",self._name)
end

return BasePlugin