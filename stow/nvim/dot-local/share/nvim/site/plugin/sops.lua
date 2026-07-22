local function f(bufnr)
    -- HACK: open in a terminal, which nests nvims, which relies on $EDITOR, and also we could just make the tempfile ourselves, but I'm too lazy to do that.
    vim.keymap.set('n', '<leader>e', '<cmd>term sops %<cr>', { buf = bufnr })
    vim.notify("This seems like a sops secret. Press `<leader>e' to edit in-place")
end

vim.filetype.add {
    extension = {
        secret = function(_, bufnr)
            local content = vim.api.nvim_buf_get_lines(bufnr, 2, 3, false)[1] or ''
            if vim.regex([[^\s*"sops": {$]]):match_str(content) ~= nil then
                return "json", f
            end
        end,
        yaml = function(_, bufnr)
            local content = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false) or {}
            for _, line in ipairs(content) do
                if vim.regex([[^sops:$]]):match_str(line) ~= nil then
                    return "yaml", f
                end
            end

            return "yaml"
        end,
    },
}
