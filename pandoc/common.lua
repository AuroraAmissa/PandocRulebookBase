local pandoc = pandoc
local PANDOC_STATE = PANDOC_STATE

local M = {}

function M.read_file(path)
    local file = io.open(path, "rb")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

function string:split(sep)
    sep = sep or '%s'
    local t = {}
    for field, s in string.gmatch(self, "([^" .. sep .. "]*)(" .. sep .. "?)") do
        table.insert(t, field)
        if s == "" then
            return t
        end
    end
    table.insert(t, "")
    return t
end

function string:contains(sub)
    return self:find(sub, 1, true) ~= nil
end

function string:startswith(start)
    return self:sub(1, #start) == start
end

function string:endswith(ending)
    return ending == "" or self:sub(- #ending) == ending
end

function string:path_parent()
    if self:contains("/") then
        return self:gsub("/[^/]+$", "")
    else
        return ""
    end
end

local json_cache = {}
function M.read_json(path)
    if not json_cache[path] then
        local file = M.read_file(path)
        if file then
            json_cache[path] = {pandoc.json.decode(file)}
        else
            json_cache[path] = {}
        end
    end
    return json_cache[path][1]
end

local real_file_cache = nil
function M.real_file()
    if not real_file_cache then
        local env = os.getenv("PAGE_FILE")
        if env then
            real_file_cache = env
        else
            real_file_cache = PANDOC_STATE.input_files[1]
        end
    end
    return real_file_cache
end

function M.origin_file()
    local raw_path = M.real_file()
    local origin_info = M.read_json("build/run/origins.json")
    return origin_info[raw_path] or raw_path
end

function M.short_path()
    local raw_path = M.real_file()
    local short_path_info = M.read_json("build/run/short_paths.json")
    return short_path_info[raw_path] or raw_path
end

function M.strip_prefix(base, source)
    if #base == 0 then
    	return source
    end
    if not source:startswith(base) then
        error("Path does not start with '" .. base .. "'")
    end
    return source:sub(#base + 1)
end

local function with_trailing(p)
    if p == "" then
        return p
    else
        return p .. "/"
    end
end

function M.relative_to(base, source, target)
    source = M.strip_prefix(base, source):path_parent()
    target = M.strip_prefix(base, target)
    local prefix = ""

    while not target:startswith(with_trailing(source)) do
    	source = source:path_parent()
    	prefix = prefix .. "../"
    end

    if source == target then
        if prefix == "" then
        	return "."
        else
            return prefix:sub(1, #prefix - 1)
        end
    end
    if #source > 0 and not source:endswith("/") then
        source = source .. "/"
    end
    return prefix .. M.strip_prefix(source, target)
end

return M
