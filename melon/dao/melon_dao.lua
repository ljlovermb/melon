local base_dao = require("melon.mysql.base_dao")
local logger_factory = require("melon.utils.logger")
local logger = logger_factory:get_logger("melon_dao.lua", context)
local json = require("cjson")

local type = type
local tinsert = table.insert
local ipairs = ipairs

local _M = base_dao:new()

function _M:load_all_plugins()
    local sql = 'select `id`,`key`,`value` from `plugins` where `type` = ?'
    local res, err = self:query(sql, { "enable" })

    if err then
        logger:warn("It was falied to loaded plugins. please check the following tips: %s", err)
        return nil
    end

    local plugins = {}
    local pos = 1
    if res and type(res) == 'table' and #res > 0 then
        for _, plugin in ipairs(res) do
            tinsert(plugins, pos, plugin.key)
            pos = pos + 1;
        end
    end

    return plugins
end

function _M:loads_all_service_nodes()
    local sql = 'select `key`,`value` from service_instance where `type` = ?'
    local res, err = self:query(sql, { "enable" })

    if err then
        logger:warn("Error to loaded service and its nodes. please check the following tips: %s", err)
        return nil
    end

    local service_and_nodes = {}
    if res and type(res) == 'table' and #res > 0 then
        for _, v in pairs(res) do
            local services = json.decode(v.value)
            local service_name = services.service
            local load_balance = services.load_balance
            local nodes = services.nodes

            tinsert(service_and_nodes, {
                service_name = service_name,
                load_balance = load_balance,
                nodes = nodes
            })
        end
    end

    return service_and_nodes
end

return _M