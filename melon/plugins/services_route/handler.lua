local base_plugins  = require("melon.plugins.base_handler")
local logger        = require("melon.utils.logger"):get_logger("services_route/handler.lua",context)
local json          = require "cjson"
local melon_utils   = require("melon.utils.melon_utils")
local r             = require("melon.utils.result.r")
local sgsub         = string.gsub

local services_route_handler = base_plugins:extend()
services_route_handler.PRIORITY = 0
services_route_handler.DELAY = 0

local function get_target_service()
    local t_g = ngx.req.get_uri_args()["t"]
    local t_p = ngx.req.get_post_args()["t"]

    if not t_g and not t_p then
        ngx.say(r.illegal_argument('t'))
        logger:warn()
        return ngx.exit
    end

    return t_g or t_p
end

function services_route_handler:new()
    services_route_handler.super:new('services_route_plugin')
end

function services_route_handler:access()
    logger:info('[Host & URI ]: http://%s%s',ngx.var.host,ngx.var.uri)
    logger:info('[Query Params]: %s', json.encode(ngx.req.get_uri_args()))
    ngx.req.read_body()
    logger:info('[Post Params]: %s', json.encode(ngx.req.get_post_args()))
    logger:info('[Header Params]: %s', json.encode(ngx.req.get_headers()))
end

function services_route_handler:rewrite()

    local st_g = ngx.req.get_uri_args()["st"]

    local st_p = ngx.req.get_post_args()["st"]

    local interface = st_g or st_p



    local target_uri = ''
    sgsub(interface,'[^.]+', function (w)
        target_uri = target_uri .. '/' .. w
    end)

    local service_name = t_g or t_p

    if not service_name then

    end

    ngx.ctx.rewrite_uri = target_uri
    ngx.ctx.upstream = melon_utils.dyups_name(service_name)

    ngx.exec()
    --local proxy_url = 'http://' .. platform .. target_uri
end

return services_route_handler