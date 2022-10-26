local utils = require('plugwatch.utils')
local async_utils = require('plenary.async.util')

local Git = {}

function Git:new(path)
    local o = path and { path = path } or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function Git:name()
    return vim.fn.fnamemodify(self.path, ':t')
end

function Git:_git(options)
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

function Git:is_git_repo()
    local job, _ = self:_git({
        args = { 'rev-parse', '--is-inside-work-tree' },
    })
    local stdout = job:result()[1]

    return stdout and vim.trim(stdout) == 'true'
end

function Git:current_branch()
    local job, _ = self:_git({
        args = { 'branch', '--show-current' },
    })

    local stdout = job:result()[1]

    return stdout and vim.trim(stdout)
end

function Git:fetch()
    local _, rc = self:_git({
        args = { 'remote', 'update' },
    })

    return rc == 0
end

function Git:new_commits()
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

function Git:update()
    self:fetch()

    return self:new_commits()
end

return Git
