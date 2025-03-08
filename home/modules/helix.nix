{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.helix;
in {
  options.modules.helix = {
    enable = lib.mkEnableOption "install and configure hx";
    use-nix-colors = lib.mkEnableOption "refer to nix-colors for theme";

    lsp = {
      enable = lib.mkEnableOption "download servers";
      extraLspServers = lib.mkOption {
        description = "extra LSP servers you want available in hx";
        default = [];
        type = lib.types.listOf lib.types.package;
      };
    };
  };

  config.programs.helix = lib.mkIf cfg.enable {
    enable = true;
    defaultEditor = true;
    settings = {
      theme =
        if cfg.use-nix-colors
        then builtins.replaceStrings ["-"] ["_"] config.colorScheme.slug
        else "catppuccin_mocha";

      editor = {
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        lsp = {
          display-inlay-hints = true;
        };

        line-number = "relative";
        cursorline = true;
        rulers = [80 100];
        bufferline = "multiple";
        end-of-line-diagnostics = "warning";

        auto-save = {
          focus-lost = true;
          after-delay.enable = true;
        };

        indent-guides.enable = true;
      };

      keys.normal = {
        G = "goto_file_end";
      };

      keys.normal."+" = {
        m = ":run-shell-command make";
        j.b = ":run-shell-command just build";
        j.r = ":run-shell-command just run";
        c.b = ":run-shell-command cargo build";
        c.t = ":run-shell-command cargo test";
      };

      keys.insert = {
        # Doesn't work for some reason
        # C-1 = "@<C-s>ghwc# <esc><C-o>i";
        # C-2 = "@<C-s>ghwc## <esc><C-o>i";
        # C-3 = "@<C-s>ghwc### <esc><C-o>i";
        # C-4 = "@<C-s>ghwc#### <esc><C-o>i";
      };
    };
    extraPackages = lib.mkIf cfg.lsp.enable (with pkgs;
      [
        marksman
        nixd
        rust-analyzer
        bash-language-server
      ]
      ++ cfg.lsp.extraLspServers);
  };
}
