local utils = require('plugwatch.utils')
local config = require('plugwatch.config')
local CodeDirectory = require('plugwatch.types').CodeDirectory

local M = {}

function M.determine_plugin_manager()
    local managers = require('plugwatch.managers')
    for _, manager in pairs(managers) do
        if manager.are_using() then
            return manager
        end
    end
end

function M.check_for_updates()
    local manager = M.determine_plugin_manager()
    if not manager then
        utils.anotify("Couldn't determine plugin manager.")
        return
    end

    local plugins = manager.get_plugins()
    local jobs = vim.tbl_map(function(path)
        return function()
            local repo = CodeDirectory:new(path)

            local _, result = xpcall(function()
                if not repo:is_git_repo() then
                    error('Not a Git repo.')
                end

                return repo:update()
            end, function(result)
                if config.debug then
                    utils.anotify('[' .. repo:name() .. '] ' .. result)
                end
            end)

            return result
        end
    end, plugins)

    local updates = utils.join_assoc(jobs)

    return vim.tbl_map(function(result) return table.unpack(result) end, updates)
end

return M
