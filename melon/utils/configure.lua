----------------------------------------------------------------
-- Title: read and write configure file.
-- Auth: Morris
-- CreateDate: 2020-12-22 13:41:37
----------------------------------------------------------------
local _M = {}

function _M.read_file(path)
    assert(type(path) == 'string', 'The parameter of \'path\' must be a string.')

    local file, msg = io.open(path, 'r')
    if not file then
        return nil, 'Error loading the file:' .. path .. ',the reason is ' .. msg
    end

    local data = {}
    local section

    for line in file:lines() do
        local tempSection = line:match('^%[([^%[%]]+)%]$')
        if tempSection then
            section = tonumber(tempSection) and tonumber(tempSection) or tempSection
            data[section] = data[section] or {}
        end
        local param, value = line:match('^([%w|_]+)%s-=%s-(.+)$')
        if param and value then
            if tonumber(value) then
                value = tonumber(value)
            elseif value == 'true' then
                value = true
            elseif value == 'false' then
                value = false
            end
            if tonumber(param) then
                param = tonumber(param)
            end
            data[section][param] = value
        end
    end

    file:close()
    return data, 'ok'
end

function _M.write_file(path, data)
    assert(type(path) == 'string', 'The parameter of \'path\' must be a string.')
    assert(type(data) == 'table', 'The parameter of \'data\' must be a table.')

    local file, msg = io.open(path, 'w+b')
    if not file then
        return 'Error loading the file:' .. path .. ',the reason is ' .. msg
    end

    local contents = ''
    for section, param in pairs(data) do
        contents = contents .. ('[%s]\n'):format(section)
        for key, value in pairs(param) do
            contents = contents .. ('%s=%s\n'):format(key, tostring(value))
        end
        contents = contents .. '\n'
    end
    file:write(contents)
    file:close()
end

function _M:read_section(ini_path,section)
    local data,err = self.read_file(ini_path)

    if not data then
        return nil,err
    end

    return data[section]
end

function _M:read_data(ini_path, section, key)
    local data,err = self.read_file(ini_path)
    if not data then
        return nil, err
    end
    return data[section][key],'ok'
end

function _M:write_data(ini_path, section, key,value)
    local data,err = self.read_file(ini_path)

    if not data then
        return false,err
    end

    data[section][key] = value
    self.write_file(ini_path, data)
    return true,'ok'
end

return _M