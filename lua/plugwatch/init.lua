local a = require('plenary.async')
local updates = require('plugwatch.updates')
local config = require('plugwatch.config')

local M = {}

---@param step number
local function increment_count(step)
    vim.g.plugwatch_updates_count = vim.g.plugwatch_updates_count + step
end

---@async
---@type fun()
local async_update_check = a.void(function()
    local found = updates.check_for_updates() or {}

    vim.g.plugwatch_updates_count = 0
    vim.g.plugwatch_updates = found

    for _, count in pairs(found) do
        if count > 0 then
            increment_count(1)
        end
    end
end)

---@async
-- Schedule a manual update check.
--
-- The public `check_for_updates` is just a getter for this method, which is
-- private so that it can't be accidentally monkeypatched.
local function _check_for_updates()
    vim.schedule(async_update_check)
end

---@type fun(): string
function M.get_statusline_indicator()
    local count = vim.g.plugwatch_updates_count or 0
    if count > 0 then
        return ''
    end

    return config.make_indicator(count, vim.g.plugwatch_updates)
end

function M.plugins_with_updates()
    local have_updates = {}
    for plugin, count in pairs(vim.g.plugwatch_updates) do
        if count > 0 then
            have_updates[plugin] = count
        end
    end

    return have_updates
end

---@async
-- Schedule a manual update check.
function M.check_for_updates()
    _check_for_updates()
end

---@param opts Config
function M.setup(opts)
    if opts ~= nil then
        vim.tbl_deep_extend('force', config, opts)
    end

    vim.g.plugwatch_updates_count = 0

    local callback = _check_for_updates

    vim.api.nvim_create_autocmd('VimEnter', {
        callback = callback,
    })

    local manager = updates.determine_plugin_manager()
    if manager ~= nil then
        manager.setup_refresh(callback)
    end
end

return M
