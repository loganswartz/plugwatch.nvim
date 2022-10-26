local M = {}

M.PluginManager = {}
M.PluginManager.__index = M.PluginManager

function M.PluginManager:new(obj)
    setmetatable(obj, self)

    return obj
end

function M.PluginManager.are_using()
    return false
end

function M.PluginManager.get_plugins()
    return {}
end

function M.PluginManager.setup_refresh(callback)
end

return M
