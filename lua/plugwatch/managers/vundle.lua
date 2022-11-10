local PluginManager = require('plugwatch.types').PluginManager
local macros = require('plugwatch.macros')

local vundle = PluginManager:new({
    are_using = function()
        return vim.g['vundle#bundles'] ~= nil
    end,
    get_plugins = function()
        local plugins = {}
        for name, bundle in pairs(vim.g['vundle#bundles']) do
            plugins[name] = bundle.path()
        end

        return plugins
    end,
    setup_refresh = macros.refresh_on_buf_leave('vundle'),
})

return vundle
