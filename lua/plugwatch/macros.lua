local M = {}

function M.refresh_on_buf_leave(ft)
    return function(callback)
        vim.api.nvim_create_autocmd('BufWinLeave', {
            pattern = '*',
            callback = function(opts)
                if vim.bo[opts.buf].filetype == ft then
                    callback()
                end
            end,
        })
    end
end

return M
