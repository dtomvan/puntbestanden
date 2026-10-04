{
  # yes it's lua again, it's simply more concise
  flake.modules.nixvim.default.extraConfigLua = ''
    vim.keymap.set('n', ':', ';')
    vim.keymap.set('n', ';', ':')
    vim.keymap.set('n', '<leader>y', 'mlggyG`l')
    vim.keymap.set('n', '<localleader><cr>', '<cr>')
    vim.keymap.set('x', 'S', function() MiniSurround.add('visual') end, { silent = true })
    vim.keymap.set('n', 'yss', 'ys_', { remap = true })
  '';
}
