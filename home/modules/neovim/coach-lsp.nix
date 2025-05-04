{
  config,
  pkgs,
  ...
}:
let
  cmd = "${pkgs.coach-cached}/bin/coach-lsp";
in
{
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
  config.programs.nixvim.plugins.lsp.enabledServers = [
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
