---@diagnostic disable: undefined-global
vim.keymap.set("n", "<leader>ep", function() Snacks.picker.projects { confirm = { "tcd", "close" } } end,
    { desc = "open projects" })
vim.keymap.set("n", "<leader>ez", function() Snacks.picker.zoxide { confirm = { "tcd", "close" } } end,
    { desc = "open zoxide" })
vim.keymap.set("n", "<c-e>", Snacks.picker.files)
vim.keymap.set("n", "<c-p>", Snacks.picker.grep)
vim.keymap.set("n", "<leader><leader>", Snacks.picker.smart, { desc = "snacks smart" })
vim.keymap.set("n", "<leader>fs", Snacks.picker.pickers, { desc = "snacks pickers" })
vim.keymap.set("n", "<leader>gl", Snacks.picker.git_log, { desc = "git log" })
vim.keymap.set("n", "<leader>gs", Snacks.picker.git_status, { desc = "git status" })
vim.keymap.set("n", "<leader>ld", Snacks.picker.diagnostics, { desc = "lsp diagnostics" })
