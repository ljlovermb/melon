local base_plugins  = require("melon.plugins.base_handler")
local melon_dao     = require("melon.dao.melon_dao"):new()
local logger        = require("melon.utils.logger"):get_logger("load_dyups/handler.lua",context)
local json          = require("cjson")
local dyups         = require("ngx.dyups")
local melon_utils    = require("melon.utils.melon_utils")
local ipairs        = ipairs
local tinsert       = table.insert
local service_nodes = ngx.shared["service_nodes"]

local loads_dynamic_upstream_handler = base_plugins:extend()
loads_dynamic_upstream_handler.PRIORITY = 0
loads_dynamic_upstream_handler.DELAY = 10

function loads_dynamic_upstream_handler:new()
    loads_dynamic_upstream_handler.super:new('loads_dynamic_upstream_plugin')
end

local function update_ups(service,ups_string)
    --[[
    local t = io.popen("curl -d \"server 172.21.36.215:8085; server 172.21.36.215:8087;\"
            http://127.0.0.1:18686/upstream/" .. service)
    logger:info("execute:%s",t:read("*all"))
    ]]

    local stat,msg = dyups.update(melon_utils.dyups_name(service),ups_string)
    if stat ~= ngx.HTTP_OK then
        return false,msg
    else
        return true,msg
    end
end

local function get_needs_reload_services()
    local service_nodes_new = melon_dao:loads_all_service_nodes()

    local needs_reload_dups = {}
    if not service_nodes_new or #service_nodes_new < 1 then
        logger:error("Error loads service and its nodes.please check the following tips: %s",service_nodes_new)
        return needs_reload_dups
    end

    for _,service in ipairs(service_nodes_new) do
        local service_name = service.service_name
        local load_balance = service.load_balance
        local nodes = service.nodes
        local keeps_shared_dict = {}

        tinsert(keeps_shared_dict,{
            load_balance = load_balance,
            nodes = nodes
        })

        local new_service_nodes_json = json.encode(keeps_shared_dict) or ''
        local old_service_nodes_json = service_nodes:get(service_name) or ''
        local changed = old_service_nodes_json ~= new_service_nodes_json

        if not old_service_nodes_json or changed then
            logger:info("The settings of service '%s' was changed. preparing to reloads the upstream.",service_name)
            service_nodes:set(service_name,new_service_nodes_json)
            tinsert(needs_reload_dups,{service_name = service_name})
        end
    end

    return needs_reload_dups
end

local function reloads_dyups(needs_reload_dups)
    if #needs_reload_dups < 1 then
        logger:info("There were no any service's settings been changed. no need to reload upstream.")
        return
    end

    for _, service in ipairs(needs_reload_dups) do
        local service_name = service.service_name

        xpcall(function ()
            local keeps_shared_dict = json.decode(service_nodes:get(service_name))

            for _,v in ipairs(keeps_shared_dict) do
                local load_balance = v.load_balance
                local nodes = v.nodes

                local ups_string = load_balance .. ";"
                for _,node in ipairs(nodes) do
                    local ip = node.ip
                    local port = node.port
                    ups_string = ups_string .. " server " .. ip .. ":" .. port .. ";"
                end

                local stat,msg = update_ups(service_name,ups_string)
                if not stat then
                    error(msg)
                else
                    logger:info("The upstream of service '%s' was reloaded done.",service_name)
                end
            end

        end,function (err)
            logger:error("Coundn't to reload the upstream of service: %s.error: %s",service_name,err)
            service_nodes:set(service_name,nil)
        end)
    end
end

function loads_dynamic_upstream_handler.init_work()
    logger:info("init worker.....")
    loads_dynamic_upstream_handler.super:init_work()
    local needs_reload_dups = get_needs_reload_services()
    reloads_dyups(needs_reload_dups)
end

function loads_dynamic_upstream_handler.reloads_dyups_manual()
    local needs_reload_dups = get_needs_reload_services()
    reloads_dyups(needs_reload_dups)
end

function loads_dynamic_upstream_handler.view_all_of_dyups()
    local t = io.popen("curl http://127.0.0.1:18686/list")
    return tostring(t:read("*all"))
end

function loads_dynamic_upstream_handler.timed_task()
    local needs_reload_dups = get_needs_reload_services()
    reloads_dyups(needs_reload_dups)
end

return loads_dynamic_upstream_handler