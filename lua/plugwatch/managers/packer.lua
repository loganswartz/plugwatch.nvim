local PluginManager = require('plugwatch.types').PluginManager

local packer = PluginManager:new({
    are_using = function()
        return _G.packer_plugins ~= nil
    end,
    get_plugins = function()
        local plugins = {}
        for name, info in pairs(_G.packer_plugins) do
            if info.enabled == nil or info.enabled then
                plugins[name] = info.path
            end
        end

        return plugins
    end,
    setup_refresh = function(callback)
        vim.api.nvim_create_autocmd('User', {
            pattern = 'PackerComplete',
            callback = callback,
        })
    end,
})

return packer
