local Job = require('plenary.job')
local a = require('plenary.async')
local async_utils = require('plenary.async.util')

local M = {}

function M.make_async_job(options)
    return a.wrap(function(callback)
        local function pack(job, rc) callback({ job, rc }) end

        local j = Job:new(vim.tbl_extend('force', options, { on_exit = pack }))

        j:start()
    end, 1)
end

function M.join_assoc(async_fns)
    -- lock the keys into a specific order
    local keymap = vim.tbl_add_reverse_lookup(vim.tbl_keys(async_fns))

    -- build a values array with that same order
    local values = {}
    for idx, value in ipairs(keymap) do
        values[idx] = async_fns[value]
    end

    -- run the functions
    local futures = async_utils.join(values)

    local results = {}
    for idx, value in ipairs(futures) do
        results[keymap[idx]] = value
    end

    return results
end

function M.collect(...)
    local arr = {}
    for v in ... do
        arr[#arr + 1] = v
    end
    return arr
end

function M.find_files(module)
    if type(module) == 'table' then
        module = table.concat(module, '/')
    end

    local rtp = vim.opt.rtp._value
    local normalized = 'lua/' .. string.gsub(module, '%.', '/')

    local files = vim.fn.globpath(rtp, normalized .. '/*.lua', nil, true) or {}
    local modules = vim.fn.globpath(rtp, normalized .. '/*/init.lua', nil, true) or {}

    local function omit_init_lua(item)
        local matches = string.gmatch(item, '.*/' .. normalized .. '/init.lua')
        return #M.collect(matches) == 0
    end

    local filtered = vim.tbl_extend('force', vim.tbl_filter(omit_init_lua, files), modules)

    local function unmap_path(path)
        return vim.fn.fnamemodify(path, ':t:r')
    end

    local converted = vim.tbl_map(unmap_path, filtered)
    return converted
end

-- Autoloads all modules inside the namespace, and returns a map of module_name => require('module_name')
function M.autoload_submodule_map(namespace)
    if type(module) == 'table' then
        namespace = table.concat(namespace, '/')
    end

    local mapping = {}
    for _, module in pairs(M.find_files(namespace)) do
        mapping[module] = require(namespace .. '.' .. module)
    end

    return mapping
end

function M.anotify(msg)
    vim.schedule(function()
        vim.notify(msg)
    end)
end

return M
