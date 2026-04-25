{
  # yes it's lua again, it's simply more concise
  flake.modules.nixvim.default.extraConfigLua = ''
    vim.keymap.set('n', ':', ';')
    vim.keymap.set('n', ';', ':')
    vim.keymap.set('n', '<leader>y', 'mlggyG`l')
    vim.keymap.set('n', '<localleader><cr>', '<cr>')
    vim.keymap.set('n', '<leader>j', '<cmd>cnext<cr>')
    vim.keymap.set('n', '<leader>k', '<cmd>cprev<cr>')
  '';
}
