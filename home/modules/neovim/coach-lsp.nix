{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.modules.coach-lsp;
  cmd = "${pkgs.coach-cached}/bin/coach-lsp";
in
{
  options.modules.coach-lsp = {
    enable = lib.mkEnableOption "download coach-lsp and add to nvim";
    use-cached = lib.mkEnableOption "don't compile coach-lsp, just use a distributed version";
  };
  config.programs.nixvim.plugins.lsp.preConfig = ''
    local configs = require 'lspconfig.configs'

    configs["coach-lsp"] = {
    	default_config = {
    		root_dir = vim.fs.dirname,
    		cmd = { '${cmd}' },
    		filetypes = {'coach'},
    		name = 'coach-lsp',
    	}
    }
  '';
  config.programs.nixvim.filetype.extension.coach = "coach";
  config.programs.nixvim.plugins.lsp.enabledServers = lib.optionals config.modules.coach-lsp.enable [
    {
      name = "coach-lsp";
      extraOptions = {
        autostart = true;
        on_attach.__raw = ''
           function(client, bufnr)
          ${config.programs.nixvim.plugins.lsp.onAttach}
           end
        '';
      };
    }
  ];
}
