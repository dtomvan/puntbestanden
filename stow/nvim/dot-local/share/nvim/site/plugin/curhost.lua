vim.api.nvim_create_user_command("Config", "e $NH_FLAKE/modules/hosts/`hostname`.nix", {})
vim.keymap.set("n", "<leader>ec", "<cmd>Config<cr>gg")
