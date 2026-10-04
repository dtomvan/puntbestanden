vim.api.nvim_create_user_command("StowDir", "cd ~/.local/share/nvim/site/", {})
vim.keymap.set("n", "<leader>es", "<cmd>StowDir<cr>")
