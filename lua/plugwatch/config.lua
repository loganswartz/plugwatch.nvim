---@class Config
---@field make_indicator IndicatorFunction The factory function to use for the statusline indicator.
---@field debug boolean Should error messages be shown?

---@alias PluginManifest { [string]: integer }
---@alias IndicatorFunction fun(count: number, manifest: PluginManifest): string

---@type Config
local default = {
    ---@type IndicatorFunction
    make_indicator = function(count, manifest)
        return table.concat({ '▲', count }, ' ')
    end,
    debug = false,
}

---@type Config
local M = vim.deepcopy(default)

M.update = function(opts)
  local new = vim.tbl_deep_extend("force", default, opts or {})

  for k, v in pairs(new) do
    M[k] = v
  end
end

return M
