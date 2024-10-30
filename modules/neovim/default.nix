{ pkgs, lib, config, ...}: {
  options = {
    neovim.enable = lib.mkEnableOption "install and configure neovim";
    neovim.lsp = {
      enable = lib.mkEnableOption "use lspconfig and download servers";
      extraLspServers = lib.mkOption {
        description = "extra LSP servers you want available in neovim";
        default = {};
        type = lib.types.attrs;
      };
    };
  };

  imports = [
    ./opts.nix
    ./keymaps.nix
    ./plugins
  ];

  config = lib.mkIf config.neovim.enable {
    xdg.configFile.".config/nvim/inspirational_quotes.txt".source = ./inspirational_quotes.txt;
    programs.nixvim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
      withRuby = false;
      extraPackages = with pkgs; [
        wl-clipboard
      ];

      clipboard.register = "unnamedplus";

      performance = {
        byteCompileLua = {
          enable = true;
          initLua = false;
          plugins = true;
        };
      };

      autoGroups = {
        LastPlace = { clear = true; };
      };
      autoCmd = [
        {
          event = "BufReadPost";
          group = "LastPlace";
          callback = { __raw = /*lua*/ ''
            function()
              local mark = vim.api.nvim_buf_get_mark(0, '"')
              local lcount = vim.api.nvim_buf_line_count(0)
              if mark[1] > 0 and mark[1] <= lcount then
                pcall(vim.api.nvim_win_set_cursor, 0, mark)
              end
            end
          ''; };
        }
      ];

      plugins.lsp = lib.mkIf config.neovim.lsp.enable {
        enable = true;
        inlayHints = true;
        servers = {
          lua_ls.enable = true;
        } // config.neovim.lsp.extraLspServers;
      };

      extraFiles."after/plugin/extra-config.lua".source = ./extra-config.lua;
      extraFiles."after/plugin/mini-starter.lua".source = ./mini-starter.lua;
    };
  };
}

# vim:sw=2 ts=2 sts=2
