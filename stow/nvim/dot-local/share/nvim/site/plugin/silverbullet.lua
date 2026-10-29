vim.pack.add { "https://github.com/eyko139/silverbullet.nvim" }
require("silverbullet").setup({
    default_space = "cs",
    spaces = {
        notes = {
            url = "https://sb.toostveen.nl/notes",
            auth = {
                command = {
                    "cat",
                    os.getenv("HOME") .. "/.config/sops-nix/secrets/sbt"
                },
            },
        },
        cs = {
            url = "https://sb.toostveen.nl/cs",
            auth = {
                command = {
                    "cat",
                    os.getenv("HOME") .. "/.config/sops-nix/secrets/sbt"
                },
            },
        },
    },
})

vim.keymap.set("n", "<leader>sf", "<Plug>(SilverBulletFind)", { desc = "Find SilverBullet page" })
vim.keymap.set("n", "<leader>sk", "<Plug>(SilverBulletSetToken)", { desc = "Set SilverBullet token" })
vim.keymap.set("n", "<leader>ss", "<Plug>(SilverBulletSearch)", { desc = "Search SilverBullet pages" })
vim.keymap.set("n", "<leader>sS", "<Plug>(SilverBulletSearchAll)", { desc = "Search all SilverBullet pages" })
vim.keymap.set("n", "<leader>sb", "<Plug>(SilverBulletBacklinks)", { desc = "Show SilverBullet backlinks" })
vim.keymap.set("n", "<leader>so", "<Plug>(SilverBulletOpenWeb)", { desc = "Open SilverBullet page in browser" })
vim.keymap.set("n", "<leader>sj", "<Plug>(SilverBulletJournal)", { desc = "Open today's SilverBullet journal page" })
vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "silverbullet://*",
    callback = function(event)
        vim.keymap.set(
            "n",
            "<CR>",
            "<Plug>(SilverBulletFollowLink)",
            {
                buffer = event.buf,
                desc = "Follow SilverBullet link",
            }
        )
        vim.keymap.set(
            "n",
            "gd",
            "<Plug>(SilverBulletFollowLink)",
            {
                buffer = event.buf,
                desc = "[G]oto SilverBullet [D]efinition",
            }
        )
    end,
})
