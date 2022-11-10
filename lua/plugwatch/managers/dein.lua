local PluginManager = require('plugwatch.types').PluginManager
local macros = require('plugwatch.macros')

local dein = PluginManager:new({
    are_using = function()
        return vim.g['dein#_plugins'] ~= nil
    end,
    get_plugins = function()
        local plugins = {}
        for name, plugin in pairs(vim.g['dein#_plugins']) do
            plugins[name] = plugin.path
        end

        return plugins
    end,
    setup_refresh = macros.refresh_on_buf_leave('SpaceVimPlugManager'),
})

return dein
