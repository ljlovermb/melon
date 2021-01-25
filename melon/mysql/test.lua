local logger    = require("melon.utils.logger") :get_logger("test.lua",context)


local melon_dao = require("melon.dao.melon_dao")
melon_dao:loads_all_service_nodes()

--for _,plugin in ipairs(plugins) do
--    logger:info("plugin:%s",plugin)
--end

--local melon = require("melon.melon")
--melon:init(context)
package.path = '/data/git/melon/?.lua;/usr/local/openresty/lualib/?.lua;'
package.cpath = '/data/git/melon/?.so;/usr/local/openresty/lualib/?.so;'

local result_type = require("melon.utils.result.result_type")
local json = require("cjson")
local r = require("melon.utils.result.r")

ngx.status = r.HTTP_MELON_ERROR
ngx.say(json.encode(result_type.ok()))
ngx.say(json.encode(result_type.illegal_argument_error('t')))
return ngx.exit(r.HTTP_MELON_ERROR)