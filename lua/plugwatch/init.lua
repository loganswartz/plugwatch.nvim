local a = require('plenary.async')
local updates = require('plugwatch.updates')

local M = {}

---@param step number
local function increment_count(step)
    vim.g.plugwatch_updates_count = vim.g.plugwatch_updates_count + step
end

---@type fun()
local check_for_updates = a.void(function()
    local found = updates.check_for_updates() or {}

    vim.g.plugwatch_updates_count = 0
    vim.g.plugwatch_updates = found

    for _, count in pairs(found) do
        if count > 0 then
            increment_count(1)
        end
    end
end)

---@alias PluginManifest { [string]: integer }
---@alias IndicatorFunction fun(count: number, manifest: PluginManifest): string

---@type IndicatorFunction
local function make_indicator(count, manifest)
    return table.concat({'▲', count }, ' ')
end

---@type fun(): string
function M.get_statusline_indicator()
    local count = vim.g.plugwatch_updates_count or 0
    if count > 0 then
        return make_indicator(count, vim.g.plugwatch_updates)
    else
        return ''
    end
end

---@class SetupOptions
---@field make_indicator IndicatorFunction

---@param opts SetupOptions
function M.setup(opts)
    if opts ~= nil then
        if opts.make_indicator ~= nil then
            make_indicator = opts.make_indicator
        end
    end

    vim.g.plugwatch_updates_count = 0

    local callback = function()
        vim.schedule(check_for_updates)
    end

    vim.api.nvim_create_autocmd('VimEnter', {
        callback = callback,
    })

    local manager = updates.determine_plugin_manager()
    if manager ~= nil then
        manager.setup_refresh(callback)
    end
end

return M
