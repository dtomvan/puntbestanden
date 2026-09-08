return {
    name = "gcc build",
    builder = function()
        local shortfile = vim.fn.expand("%:t")
        local file = vim.fn.expand("%:p")
        local exe = vim.fn.expand("%:p:r")
        local shortexe = vim.fn.expand("%:t:r")
        return {
            name = "build and run " .. shortfile,
            strategy = {
                "orchestrator",
                tasks = {
                    {
                        name = "build " .. shortfile,
                        cmd = { "gcc", "-o", exe, file },
                        components = {
                            {
                                "open_output",
                                on_start = "never",
                                on_complete = "failure",
                                direction = "vertical",
                            },
                            { "on_output_quickfix", items_only = true },
                            "default" },
                    },
                    {
                        name = "run " .. shortexe,
                        cmd = { exe },
                        components = { { "open_output", direction = "vertical", focus = true, open = true }, "default" },
                    },
                },
            },
        }
    end,
    condition = {
        filetype = { "c" },
    },
}
