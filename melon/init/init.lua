local version           = require("melon.version")
local logger_factory    = require("melon.utils.logger")
local read_config       = require("melon.utils.read_config")
local json              = require("cjson")

context                 = {}
context.version         = version
read_config(context)

if not context.mysql.host or not context.mysql.port or not context.mysql.user or not context.mysql.pass then
    ngx.log(ngx.ERR,"Error loading the mysql config.")
    os.exit(1)
end

if not context.log_path or not context.log_level then
    ngx.log(ngx.ERR,"Error loading the log config. please sets about the logs in the 'melon.ini'")
    os.exit(1)
end

local ok,_ = io.open(context.log_path)
if not ok then
    local index = string.find( _ ,"No such file or directory")
    if index ~= nil then
        os.execute("mkdir -p " .. context.log_path)
    end
end

local ok,_ = io.open(context.log_path)
if not ok then
    ngx.log(ngx.ERR,"Initialize logger failure. it might has no permission for the logger folder.")
    os.exit(1)
end

local logger,err = logger_factory:get_logger("init.lua",context)
if not logger then
    ngx.log(ngx.ERR,"Failed to instance logger.please check the following tips:",err)
end

local banner = require("melon.utils.banner")

logger:info(banner.alligator)

--ngx.log(ngx.INFO,"MySQL host :" .. context.mysql_host .. ",MySQL port :" .. context.mysql_port)
logger:info("The melon work space                           : \'%s\'", logger.colors.magenta(context.path))
logger:info("The melon config path                          : \'%s\'", logger.colors.magenta(context.config))
logger:info("The melon version                              : \'%s\'", logger.colors.magenta(context.version))
logger:info("The nginx version                              : \'%s\'", logger.colors.magenta(ngx.config.nginx_version))
logger:info("The nginx_lua version                          : \'%s\'", logger.colors.magenta(ngx.config.ngx_lua_version))
logger:info("Melon using mysql                              : [%s:%s]", logger.colors.magenta(context.mysql.host),logger.colors.magenta(context.mysql.port))
logger:info("Melon logs path                                : \'%s\'", logger.colors.magenta(context.log_path))
logger:info("Melon logs level                               : [%s]", logger.colors.magenta(context.log_level))

local melon = require("melon.melon")
local instance = melon:init(context)
context.instance = instance