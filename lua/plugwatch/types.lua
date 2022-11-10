local M = {}

---@class PluginManager
---@field new fun(self: PluginManager, obj: table): PluginManager
---@field are_using fun(): boolean
---@field get_plugins fun(): { [string]: string } A mapping of plugin names to filepaths
---@field setup_refresh fun(callback: fun()) A mapping of plugin names to filepaths

---@type PluginManager
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
