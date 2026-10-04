local LastPlace = vim.api.nvim_create_augroup("LastPlace", { clear = true })
vim.api.nvim_create_autocmd("BufReadPost", {
    group = LastPlace,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

local formatter = vim.api.nvim_create_augroup("formatoptions", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
    group = formatter,
    callback = function()
        vim.opt.formatoptions:remove 'o'
    end,
})
