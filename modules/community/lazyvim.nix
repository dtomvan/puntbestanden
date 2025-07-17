# Stolen from https://github.com/LazyVim/LazyVim/discussions/1972
# Used for my guest profile
#
# You need to make an init.lua and a `lua/config/plugins.lua` yourselves,
# because that's just how lazyvim works. You can use the following NixOS
# snippet:
# ```nix
# systemd.tmpfiles.rules = [
#   "d /home/<user>/.config/nvim/lua/config 0744 <user> users -"
#   "f /home/<user>/.config/nvim/init.lua 0644 <user> users - require(\"config.lazy\")"
#   "f /home/<user>/.config/nvim/lua/config/plugins.lua 0644 <user> users - return {}"
# ];
# ```
{
  flake.modules.homeManager.lazyvim =
    { lib, pkgs, ... }:
    {
      programs.neovim = {
        enable = true;

        extraPackages = with pkgs; [
          # LazyVim
          lua-language-server
          stylua
          # Telescope
          ripgrep
        ];

        plugins = with pkgs.vimPlugins; [
          lazy-nvim
        ];
      };

      xdg.configFile."nvim/lua/config/lazy.lua".text =
        let
          plugins = with pkgs.vimPlugins; [
            # LazyVim
            LazyVim
            blink-cmp
            bufferline-nvim
            cmp-buffer
            cmp-nvim-lsp
            cmp-path
            cmp_luasnip
            conform-nvim
            dashboard-nvim
            dressing-nvim
            flash-nvim
            friendly-snippets
            gitsigns-nvim
            grug-far-nvim
            indent-blankline-nvim
            lazydev-nvim
            lualine-nvim
            mini-icons
            neo-tree-nvim
            neoconf-nvim
            neodev-nvim
            noice-nvim
            nui-nvim
            nvim-cmp
            nvim-lint
            nvim-lspconfig
            nvim-notify
            nvim-spectre
            # TODO: nvim-treesitter tries to create a parser dir relative to
            # itself, which would be immutable, so Lazy has to download
            # nvim-treesitter here.
            # nvim-treesitter
            # nvim-treesitter-context
            # nvim-treesitter-textobjects
            nvim-ts-autotag
            nvim-ts-context-commentstring
            nvim-web-devicons
            persistence-nvim
            plenary-nvim
            snacks-nvim
            telescope-fzf-native-nvim
            telescope-nvim
            todo-comments-nvim
            tokyonight-nvim
            trouble-nvim
            ts-comments-nvim
            vim-illuminate
            vim-startuptime
            which-key-nvim
            {
              name = "LuaSnip";
              path = luasnip;
            }
            {
              name = "catppuccin";
              path = catppuccin-nvim;
            }
            {
              name = "mini.ai";
              path = mini-nvim;
            }
            {
              name = "mini.bufremove";
              path = mini-nvim;
            }
            {
              name = "mini.comment";
              path = mini-nvim;
            }
            {
              name = "mini.indentscope";
              path = mini-nvim;
            }
            {
              name = "mini.pairs";
              path = mini-nvim;
            }
            {
              name = "mini.surround";
              path = mini-nvim;
            }
          ];
          mkEntryFromDrv =
            drv:
            if lib.isDerivation drv then
              {
                name = "${lib.getName drv}";
                path = drv;
              }
            else
              drv;
          lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
        in
        ''
          require("lazy").setup({
            defaults = {
              lazy = true,
            },
            dev = {
              -- reuse files from pkgs.vimPlugins.*
              path = "${lazyPath}",
              patterns = { "" },
              -- fallback to download
              fallback = true,
            },
            spec = {
              { "LazyVim/LazyVim", import = "lazyvim.plugins" },
              -- The following configs are needed for fixing lazyvim on nix
              -- force enable telescope-fzf-native.nvim
              { "nvim-telescope/telescope-fzf-native.nvim", enabled = true },
              -- disable mason.nvim, use programs.neovim.extraPackages
              { "williamboman/mason-lspconfig.nvim", enabled = false },
              { "williamboman/mason.nvim", enabled = false },
              -- import/override with your plugins
              { import = "config.plugins" },
              -- treesitter handled by xdg.configFile."nvim/parser", put this line at the end of spec to clear ensure_installed
              { "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = {} } },
            },
          })
        '';
    };
}
