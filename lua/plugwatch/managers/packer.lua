local M = {}

M.are_using = function()
    return _G.packer_plugins ~= nil
end

M.get_plugins = function()
    local plugins = {}
    for name, info in pairs(_G.packer_plugins) do
        if info.enabled == nil or info.enabled then
            plugins[name] = info.path
        end
    end

    return plugins
end

M.setup_refresh = function(callback)
    vim.api.nvim_create_autocmd('User', {
        pattern = 'PackerComplete',
        callback = callback,
    })
end

return M
