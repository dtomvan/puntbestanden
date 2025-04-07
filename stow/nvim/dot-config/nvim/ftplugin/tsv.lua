local bufnr = vim.api.nvim_get_current_buf()

local function set(k, v)
    vim.schedule(function()
        vim.api.nvim_set_option_value(k, v, {
            buf = bufnr,
        })
    end)
end

set("expandtab", false)
