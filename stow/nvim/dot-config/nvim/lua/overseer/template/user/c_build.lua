return {
    name = "gcc build",
    builder = function()
        local file = vim.fn.expand("%:p")
        local exe = vim.fn.expand("%:p:r")
        return {
            cmd = { "gcc", "-o", exe, file },
            components = { { "on_output_quickfix", open = true }, "default" },
        }
    end,
    condition = {
        filetype = { "c" },
    },
}
