vim.keymap.set('n', '<leader>0', function()
    local linenr = vim.fn.search('# Please enter the commit message', 'n')
    if linenr == 0 then
        return
    end
    local date = os.date '%F'
    vim.api.nvim_buf_set_lines(0, 0, linenr - 1, true, { date })
end, {
    desc = 'Replace commit message with current date',
    buffer = true,
    silent = true,
})
