local mysql_connector = require("melon.mysql.mysql_connector")
local logger_factory  = require("melon.utils.logger")
local logger = logger_factory:get_logger("base_dao.lua",context)
local table_utils = require("melon.utils.table_utils")
local json = require("cjson")

local _M = {}
local mt = { __index = _M }

function _M:new()
    return setmetatable(self,mt)
end

local function execute(sql)
    local status,connector,err = pcall(function ()
        local connector, err = mysql_connector:get_connector(context)
        if not connector then
            error(err)
        end

        return connector,err
    end)

    if not status then
        return nil,"Failed to connect to mysql.the reason is: " .. connector
    end

    logger:debug("Preparing to execute sql. sql: %s", sql)
    local res, err, errno, sqlstate = connector:query(sql)

    if res then
        logger:debug("The SQL executed done. the r.lua: %s", json.encode(res))
    elseif not res or err then
        logger:warn("Failed to execute the sql.err: %s, errno: %s, sqlstate: %s",err, errno, sqlstate)
    end

    mysql_connector:close()
    return res, err, errno, sqlstate
end

function _M:query(sql, params)
    sql = self:parse_sql(sql, params)
    return execute(sql)
end

function _M:select(sql, params)
    return self:query(sql, params)
end

function _M:insert(sql, params)
    local res, err, errno, sqlstate = self:query(sql, params)
    if res and not err then
        return  res.insert_id, err
    else
        return res, err
    end
end

function _M:update(sql, params)
    return self:query(sql, params)
end

function _M:delete(sql, params)
    local res, err, errno, sqlstate = self:query(sql, params)
    if res and not err then
        return res.affected_rows, err
    else
        return res, err
    end
end

local function split(str, delimiter)
    if str == nil or str == '' or delimiter == nil then
        return nil
    end

    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
        table.insert(result, match)
    end
    return result
end

local function compose(t, params)
    if t == nil or params == nil or type(t) ~= "table" or type(params) ~= "table" or #t ~= #params + 1 or #t == 0 then
        return nil
    else
        local result = t[1]
        for i = 1, #params do
            result = result .. params[i] .. t[i + 1]
        end
        return result
    end
end

function _M:parse_sql(sql, params)
    if not params or not table_utils.table_is_array(params) or #params == 0 then
        return sql
    end

    local new_params = {}
    for i, v in ipairs(params) do
        if v and type(v) == "string" then
            v = ngx.quote_sql_str(v)
        end

        table.insert(new_params, v)
    end

    local t = split(sql, "?")
    local sql = compose(t, new_params)

    return sql
end

return _M
