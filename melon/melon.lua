local version               = require("melon.version")
local melon_dao             = require("melon.dao.melon_dao"):new()
local melon_utils           = require("melon.utils.melon_utils")
local logger_factory        = require("melon.utils.logger")
local logger                = logger_factory:get_logger("melon.lua", context)
local cookie                = require("melon.libs.cookie")
local type                  = type
local pairs                 = pairs
local tinsert               = table.insert
local tsort                 = table.sort
local new_timer             = ngx.timer.at
local worker_id             = ngx.worker.id

local _M = {}
local mt = { __index = _M }
local loaded_plugins = {}

local function load_plugins_module(plugins)
    local sorted_plugins = {}
    if not plugins or type(plugins) ~= 'table' then
        return nil
    end

    for k, v in pairs(plugins) do
        local module = "melon.plugins." .. k .. ".handler"

        local state, load_plugin_handler = melon_utils.load_module_if_exists(module)
        if not state then
            logger:erros("Loaded the plugin module '%-12.12s'      : [ %s ]", k,logger.colors.magenta("no"))
        else
            logger:info("Loaded the plugin module '%-12.12s'       : [ %s ]", k,logger.colors.magenta("ok"))
            load_plugin_handler.PRIORITY = v
            load_plugin_handler.DELAY = context.timed[k] or 0

            tinsert(sorted_plugins, {
                name = k,
                handler = load_plugin_handler()
            })
        end
    end

    tsort(sorted_plugins, function(a, b)
        local priority_a = a.handler.PRIORITY or 0
        local priority_b = b.handler.PRIORITY or 0
        return priority_a > priority_b
    end)

    return sorted_plugins
end

function _M:init(context)
    local mysql_conf = context.mysql
    local context = context

    loaded_plugins = load_plugins_module(context.plugins)

    return setmetatable({
        version = version,
        path = context.path,
        config = context.config,
        melon_start_at = ngx.now() * 1000,
        mysql_host = mysql_conf.host,
        mysql_port = mysql_conf.port,
    }, mt)
end

function _M:version()
    return self.version
end

function _M:runtime()
    return ngx.now() * 1000 - self.melon_start_at
end

local function create_timer()
    local timed_tasks = {}
    for _, plugin in pairs(loaded_plugins) do
        local delay = plugin.handler.DELAY
        local timer_task
        local timed_task = plugin.handler.timed_task

        timer_task = function(premature)
            if premature or not delay or not timed_task or delay == 0 then
                return
            end

            local stat,err = pcall(function()
                if timed_task then
                    plugin.handler:timed_task()
                end
            end)

            new_timer(delay,timer_task)
            if not stat then
                logger:warn("Plugin %s timer task executed failed.the reason is: %s",plugin.handler:get_name(9),err)
            end
        end

        if delay then
            tinsert(timed_tasks,{
                task = timer_task,
                delay = delay,
                plugin = plugin
            })
        end
    end

    return timed_tasks
end

function _M.init_worker()
    if 0 ~= worker_id() then
        return
    end

    local timed_tasks = create_timer()

    for _,v in pairs(timed_tasks) do
        local task = v.task
        --local delay = v.delay
        local plugin = v.plugin

        local ok,_ = new_timer(0,task)

        if not ok then
            logger:warn("Plugin %-12.9s timer task created        : [ %s ]",plugin.handler:get_name(9),logger.colors.red("no"))
        else
            logger:info("Plugin %-12.9s timed task created        : [ %s ]",plugin.handler:get_name(9),logger.colors.magenta("ok"))
        end
    end

    for _, plugin in pairs(loaded_plugins) do
        plugin.handler:init_worker()
    end
end

function _M.init_cookies()
    ngx.ctx.__cookies__ = nil
    local ck,err = cookie:new()

    if not err and ck then
        ngx.ctx.__cookies__ = ck
    end
end

--function _M.set_ups()
--    local state, handler = melon_utils:load_module_if_exists("melon.plugins.services_route.handler")
--    return handler.rewrite()
--end

function _M.redirect()
    ngx.ctx.REDIRECT_START = ngx.now() * 1000

    for _,plugin in pairs(loaded_plugins) do
        plugin.handler:redirect()
    end

    local ended_time = ngx.now() * 1000
    ngx.ctx.REDIRECTED_SPEND = ended_time - ngx.ctx.REDIRECT_START
    ngx.ctx.REDIRECT_ENDED_AT = ended_time
end

function _M.rewrite()
    ngx.ctx.REWRITE_START = ngx.now() * 1000

    for _,plugin in pairs(loaded_plugins) do
        plugin.handler:rewrite()
    end

    local ended_time = ngx.now() * 1000
    ngx.ctx.REWRITED_SPEND = ended_time - ngx.ctx.REWRITE_START
    ngx.ctx.REWRITE_ENDED_AT = ended_time
end

function _M.access()
    ngx.ctx.ACCESS_START = ngx.now() * 1000
    for _,plugin in pairs(loaded_plugins) do
        plugin.handler:access()
    end

    local ended_time = ngx.now() * 1000
    ngx.ctx.ACCESSED_SPEND = ended_time - ngx.ctx.ACCESS_START
    ngx.ctx.ACCESS_ENDED = ended_time
end

function _M.header_filter()
    for _,plugin in pairs(loaded_plugins) do
        plugin.handler:header_filter()
    end
end

function _M.body_filter()
    for _,plugin in pairs(loaded_plugins) do
        plugin.handler:body_filter()
    end
end

function _M.log()
    for _,plugin in pairs(loaded_plugins) do
        plugin.handler:log()
    end
end

return _M