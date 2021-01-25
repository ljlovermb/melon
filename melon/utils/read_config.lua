local configure = require("melon.utils.configure")
local melon_path = os.getenv("MELOG_PATH") or ngx.config.prefix()
local config_file_path = melon_path .. "/conf/melon.ini"
local json = require("cjson")

local ok,_ = io.open(config_file_path)
if not ok then
    ngx.log(ngx.ERR,"Error loading the melon config file. please check following tips:",_)
    os.exit(1)
end

local function read_config(context)
    context.path            = melon_path
    context.config          = config_file_path
    local mysql             = {}

    mysql.host              = configure:read_data(config_file_path,'MySQL','host')
    mysql.port              = configure:read_data(config_file_path,'MySQL','port')
    mysql.user              = configure:read_data(config_file_path,'MySQL','user')
    mysql.pass              = configure:read_data(config_file_path,'MySQL','password')
    mysql.charset           = configure:read_data(config_file_path,'MySQL','charset')
    mysql.timeout           = configure:read_data(config_file_path,'MySQL','timeout')
    mysql.max_idle_timeout  = configure:read_data(config_file_path,'MySQL','max_idle_timeout')
    mysql.pool_size         = configure:read_data(config_file_path,'MySQL','pool_size')
    mysql.max_packet_size   = configure:read_data(config_file_path,'MySQL','max_packet_size')

    context.plugins         = configure:read_section(config_file_path,'Plugins')
    context.timed           = configure:read_section(config_file_path,"Timed")

    context.mysql           = mysql
    context.log_path        = configure:read_data(config_file_path,'LOG','path')
    context.log_level       = configure:read_data(config_file_path,'LOG','level')


    --[[
    ngx.log(ngx.INFO, "Done to read the config of the melon.mysql."
            .. "\n context.config: "           .. context.config
            .. "\n mysql.host: "               .. mysql.host
            .. "\n mysql.port: "               .. mysql.port
            .. "\n mysql.user: "               .. mysql.user
            .. "\n mysql.pass: "               .. mysql.pass
            .. "\n mysql.charset: "            .. mysql.charset
            .. "\n mysql.timeout: "            .. mysql.timeout
            .. "\n mysql.max_idle_timeout: "   .. mysql.max_idle_timeout
            .. "\n mysql.pool_size: "          .. mysql.pool_size
            .. "\n mysql.max_packet_size: "    .. mysql.max_packet_size
            .. "\n context.plugins: "          .. json.encode(context.plugins)
            .. "\n context.log_path: "         .. context.log_path
            .. "\n context.log_level: "        .. context.log_level
    )
    ]]
end

return read_config