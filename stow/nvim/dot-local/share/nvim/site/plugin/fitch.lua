vim.filetype.add {
    extension = {
        fitch = function(_, bufnr)
            if vim.fn.executable "fitchv" then
                vim.notify("This seems like a FitchVIZIER proof.")
                vim.cmd.iabbrev("<buffer>", "and", "∧")
                vim.cmd.iabbrev("<buffer>", "or", "∨")
                vim.cmd.iabbrev("<buffer>", "not", "¬")
                vim.cmd.iabbrev("<buffer>", "impl", "→")
                vim.cmd.iabbrev("<buffer>", "bic", "↔")
                vim.cmd.iabbrev("<buffer>", "bot", "⊥")
                vim.cmd.iabbrev("<buffer>", "fa", "∀")
                vim.cmd.iabbrev("<buffer>", "ex", "∃")
                vim.keymap.set("n", "<leader>r", function()
                    local curfile = vim.fn.expand("%:p")
                    local obj = vim.system({ "fitchv", "--no-template", curfile }, { text = true }):wait()
                    local level = vim.log.levels.ERROR
                    if obj.code == 0 and obj.signal == 0 then level = vim.log.levels.INFO end
                    vim.notify(obj.stdout, level)
                end, { buf = bufnr })
                vim.treesitter.start(bufnr, "fitch")
            end
            return "fitch"
        end,
    },
}
