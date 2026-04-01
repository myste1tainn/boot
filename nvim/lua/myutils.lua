-- local ENV_HOME = vim.env.HOME
local ENV_HOME = '/Users/arnon.keereena'
local M = {}

local function file_info(info)
    if info == nil then
        return "unknown.txt"
    else
        if info.source == nil then
            return {
                path = "unknown.txt",
                dir = ""
            }
        else
            local strs = M.split_string(info.source, "/")
            local index_of_lua = M.index_last_of_string(strs, "lua")
            local strs_len = table.length(strs)
            local start_index = -1
            if index_of_lua > -1 then
                start_index = index_of_lua
            else
                start_index = strs_len - 3
            end

            if start_index < 0 then start_index = 0 end
            local after_lua_strs = {unpack(strs, start_index + 1, strs_len)}
            local file_path = table.concat(after_lua_strs, "/")

            local _filename = "global"
            if info.name ~= nil and info.name ~= '?' then
                _filename = info.name
            end
            if _filename == '' then
                _filename = 'unknown_caller.txt'
            end

            return {
                path = file_path .. "/" .. _filename .. ".txt",
                dir = file_path
            }
        end
    end
end

local function mkdir(dir)
    os.execute("mkdir -p " .. dir)
end

function M.index_last_of_string(strs, str)
    local index = -1
    for k,v in pairs(strs) do if v == str then index = k end end
    return index
end

function table.length(tbl)
    local count = 0
    if type(tbl) ~= "table" then return count end
    for _,_ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Return a ISO 8061 formatted timestamp in UTC (Z)
-- @return e.g. 2021-09-21T15:20:44.323Z
function M.iso_8061_timestamp()
    local _,b = math.modf(os.clock())
    if b==0 then
        b='000'
    else
        b=tostring(b):sub(3,5)
    end
    return os.date("!%Y-%m-%dT%T.") .. b
end

function M.fwrite(str)
    local fname = file_info(debug.getinfo(2))
    local fdir = ENV_HOME .. "/Desktop/lua_debug/" .. fname.dir
    mkdir(fdir)
    local f = io.open(ENV_HOME .. "/Desktop/lua_debug/" .. fname.path, "a+")
    local now = M.iso_8061_timestamp()
    local str_to_write = now .. "\t" .. str .. "\n"
    if f == nil then
        print("file cannot be open")
    else
        f:write(str_to_write)
        f:flush()
        f:close()
    end

    f = io.open(ENV_HOME .. "/Desktop/lua_debug/" .. fname.dir .. "/all.txt", "a+")
    if f == nil then
        print("file cannot be open")
    else
        f:write(str_to_write)
        f:flush()
        f:close()
    end
end

function M.dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
            if type(k) ~= 'number' then k = '"'..k..'"' end
            s = s .. '['..k..'] = ' .. M.dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end

function M.split_string (inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

return M
