vim.loader.enable(true)

vim.pack.add {
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/nvim-mini/mini.nvim",
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-telescope/telescope.nvim",
  "https://github.com/neovim/nvim-lspconfig",
}

require 'mini.basics'.setup {
  options = {
    extra_ui = true,
    win_borders = 'single',
  },
  mappings = { windows = true, },
}
require 'mini.ai'.setup {}
require 'mini.jump'.setup {}
require 'mini.jump2d'.setup {}
require 'mini.cmdline'.setup {}
require 'mini.git'.setup {}
require 'mini.comment'.setup {}
require 'mini.statusline'.setup {}

require('mini.base16').setup {
  palette = {
    base00 = "#1e1e2e",
    base01 = "#181825",
    base02 = "#313244",
    base03 = "#45475a",
    base04 = "#585b70",
    base05 = "#cdd6f4",
    base06 = "#f5e0dc",
    base07 = "#b4befe",
    base08 = "#f38ba8",
    base09 = "#fab387",
    base0A = "#f9e2af",
    base0B = "#a6e3a1",
    base0C = "#94e2d5",
    base0D = "#89b4fa",
    base0E = "#cba6f7",
    base0F = "#f2cdcd",
  },
  use_cterm = true,
}


vim.o.ai = true
vim.o.ci = true
vim.o.et = true
vim.o.nu = true
vim.o.rnu = true
vim.o.sc = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.sts = 4
vim.o.sw = 4
vim.o.ts = 4
vim.o.virtualedit = 'block'
vim.o.wrap = true

vim.g.mapleader = '<space>'

vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist)
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>')


require 'telescope'.setup {}
vim.keymap.set("n", "<c-e>", function() require 'telescope.builtin'.find_files() end)
vim.keymap.set("n", "<c-p>", function() require 'telescope.builtin'.live_grep() end)

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('my-lsp-attach', { clear = true }),
  callback = function(ev)
    local buf = ev.buf
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { buffer = buf })
    vim.keymap.set('n', '<leader>a', vim.lsp.buf.code_action, { buffer = buf })
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = buf })
    vim.keymap.set('n', 'gO', function() require 'telescope.builtin'.lsp_document_symbols() end, { buffer = buf })
  end,
})

for _, ls in ipairs {
  "rust_analyzer",
  "lua_ls",
  "nixd",
  "gopls",
  "tinymist",
  "gleam"
} do
  vim.lsp.enable(ls)
end

vim.diagnostic.config({ update_in_insert = false, virtual_lines = false, virtual_text = { current_line = true } })

-- vim:sw=2 ts=2 sts=2 et
