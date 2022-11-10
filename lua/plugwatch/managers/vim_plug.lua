local PluginManager = require('plugwatch.types').PluginManager
local macros = require('plugwatch.macros')

local vim_plug = PluginManager:new({
    are_using = function()
        return vim.g.plugs ~= nil
    end,
    get_plugins = function()
        local plugins = {}
        for name, spec in pairs(vim.g.plugs) do
            plugins[name] = spec.dir .. (spec.rtp or '')
        end

        return plugins
    end,
    setup_refresh = macros.refresh_on_buf_leave('vim-plug'),
})

return vim_plug
