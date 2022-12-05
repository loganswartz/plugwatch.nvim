---@class Config
---@field make_indicator IndicatorFunction The factory function to use for the statusline indicator.
---@field debug boolean Should error messages be shown?

---@type Config
local M = {}

---@alias PluginManifest { [string]: integer }
---@alias IndicatorFunction fun(count: number, manifest: PluginManifest): string

---@type IndicatorFunction
function M.make_indicator(count, manifest)
    return table.concat({'▲', count }, ' ')
end

M.debug = false

return M
