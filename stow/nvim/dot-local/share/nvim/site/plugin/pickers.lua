---@diagnostic disable: undefined-global
vim.keymap.set("n", "<leader>ep", function() Snacks.picker.projects { confirm = { "tcd", "close" } } end,
    { desc = "open projects" })
vim.keymap.set("n", "<leader>ez", function() Snacks.picker.zoxide { confirm = { "tcd", "close" } } end,
    { desc = "open zoxide" })
