local mysql                 = require("resty.mysql")
local logger_factory        = require("melon.utils.logger")
local logger                = logger_factory:get_logger("mysql_connector.lua",context)
local _M                    = {}

local function set_mt(options)
    local host              = options.mysql.host
    local port              = options.mysql.port
    local database          = "melon"
    local user              = options.mysql.user
    local password          = options.mysql.pass
    local charset           = options.mysql.charset
    local max_packet_size   = options.mysql.max_packet_size
    local max_idle_timeout  = options.mysql.max_idle_timeout
    local pool_size         = options.mysql.pool_size

    return {
        host                = host,
        port                = port,
        database            = database,
        user                = user,
        password            = password,
        charset             = charset,
        max_packet_size     = max_packet_size,
        max_idle_timeout    = max_idle_timeout,
        pool_size           = pool_size
    }
end

function _M:get_connector(options)
    if ngx.ctx['mysql_pool'] then
        logger:info("Get connector from mysql_pool.")
        return ngx.ctx['mysql_pool'], "ok"
    end

    local state,db = pcall(function ()
        local db = mysql:new()
        if not db then
            error(err)
        end
        return db
    end)

    if not state then
        return nil, "Failed to instantiates mysql, please check the following tips." .. db
    end

    setmetatable(self,{ __index = set_mt(options) })
    local ok, err, errcode, sqlstate = db:connect {
        host                = self.host,
        port                = self.port,
        database            = self.database,
        user                = self.user,
        password            = self.password,
        charset             = self.charset,
        max_packet_size     = self.max_packet_size
    }
    db:set_timeout(options.mysql.timeout)

    if not ok then
        return nil, "Failed to connects to mysql. "
                .. " errcode : "    .. ( errcode or 'nil'  )
                .. ",errmsg  : "    .. ( err or 'nil'      )
                .. ",sqlstate: "    .. ( sqlstate or 'nil' )
    end

    ngx.ctx['mysql_pool'] = db
    return db, "ok"
end

function _M:close()
    if ngx.ctx['mysql_pool'] then
        local ok,err = ngx.ctx['mysql_pool']:set_keepalive(self.max_idle_timeout,self.pool_size)
        if not ok then
            logger:warn("Failed to set keepalive,the reason is: %s",err)
            ngx.ctx['mysql_pool'] = nil
        end
    end
end

return _M


