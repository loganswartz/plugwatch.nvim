local utils = require('plugwatch.utils')
local async_utils = require('plenary.async.util')

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

---@class CodeDirectory
---@field path string The filepath of the underlying directory
---@field new fun(self: CodeDirectory, path: string): CodeDirectory Create a new instance of the class.
---@field name fun(self: CodeDirectory): string Get the name of the repo.
---@field _git fun(self: CodeDirectory, options: table): (table, integer) Run a raw git command.
---@field is_git_repo fun(self: CodeDirectory): boolean Check if the directory is a repo.
---@field current_branch fun(self: CodeDirectory): string Get the current branch of the repo.
---@field fetch fun(self: CodeDirectory): boolean Fetch info on new remote commits on the repo.
---@field new_commits fun(self: CodeDirectory): integer Get the number of commits between the local and remote head on the repo.
---@field update fun(self: CodeDirectory): integer Fetch then check the number of commits.

---@type CodeDirectory
M.CodeDirectory = {}
M.CodeDirectory.__index = M.CodeDirectory

function M.CodeDirectory:new(path)
    local o = path and { path = path } or {}
    setmetatable(o, self)

    return o
end

function M.CodeDirectory:name()
    return vim.fn.fnamemodify(self.path, ':t')
end

---@async
function M.CodeDirectory:_git(options)
    if options == nil then
        options = {}
    end

    local args = vim.tbl_extend('force', { command = 'git', cwd = self.path }, options)
    local job = utils.make_async_job(args)

    local j, rc = table.unpack(job())

    -- ensure the pipes are released
    while not (j:_pipes_are_closed(self) and j.is_shutdown) do
        async_utils.sleep(100)
    end

    return j, rc
end

---@async
function M.CodeDirectory:is_git_repo()
    local job, _ = self:_git({
        args = { 'rev-parse', '--is-inside-work-tree' },
    })
    local stdout = job:result()[1]

    return stdout and vim.trim(stdout) == 'true'
end

---@async
function M.CodeDirectory:current_branch()
    local job, _ = self:_git({
        args = { 'branch', '--show-current' },
    })

    local stdout = job:result()[1]

    return stdout and vim.trim(stdout)
end

---@async
function M.CodeDirectory:fetch()
    local _, rc = self:_git({
        args = { 'remote', 'update' },
    })

    return rc == 0
end

---@async
function M.CodeDirectory:new_commits()
    local current = self:current_branch()
    if current == nil then
        --[[ utils.anotify('Could not get current branch for ' .. self:name()) ]]
        return
    end

    local target = 'origin/' .. current

    local job, _ = self:_git({
        args = { 'rev-list', 'HEAD..' .. target, '--count' },
    })
    local stdout = job:result()[1]

    return stdout and tonumber(vim.trim(stdout))
end

---@async
function M.CodeDirectory:update()
    self:fetch()

    return self:new_commits()
end

return M
