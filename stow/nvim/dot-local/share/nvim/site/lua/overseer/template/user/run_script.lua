return {
    name = "run script",
    builder = function()
        local file = vim.fn.expand("%:p")
        local cmd = { file }
        if vim.bo.filetype == "go" then
            cmd = { "go", "run", file }
        elseif vim.bo.filetype == "python" then
            cmd = { "python", file }
        end
        return {
            cmd = cmd,
            components = {
                { "open_output", direction = "vertical", focus = true, open = true },
                "default",
            },
        }
    end,
    condition = {
        filetype = { "sh", "python", "go" },
    },
}
