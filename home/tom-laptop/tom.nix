{
  pkgs,
  lib,
  nix-colors,
  htmlDocs,
  ...
}: let
  username = "tomvd";
  docs = pkgs.makeDesktopItem {
    name = "nixos-manual";
    desktopName = "NixOS Manual";
    genericName = "System Manual";
    comment = "View NixOS documentation in a web browser";
    icon = "nix-snowflake";
    exec = "${pkgs.xdg-utils}/bin/xdg-open ${htmlDocs}/share/doc/nixos/index.html";
    categories = ["System"];
  };
in {
  imports = [
    ../../modules/basic-cli
    ../../modules/terminals

    ../../modules/firefox.nix
    ../../modules/syncthing.nix
  ];

  firefox = {
    enable = true;
    isPlasma = true;
  };

  modules = {
    terminals.enable = true;
    terminals.ghostty = {
      enable = true;
      default = true;
      font = {
        size = 14;
        family = "Afio";
      };
    };
    terminals.foot = {
      enable = true;
      default = false;
      font = {
        size = 14;
        family = "Afio";
      };
    };

    # neovim.use-nix-colors = false;
    neovim.lsp = {
      enable = true;
      # nixd.enable = false;
      rust_analyzer.enable = true;
    };
  };

  services.lorri.enable = true;
  xdg.mimeApps.enable = lib.mkForce false;

  nix.gc.automatic = true;

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.05";

  colorScheme = nix-colors.colorSchemes.catppuccin-mocha;

  news.display = "silent";
  news.entries = lib.mkForce [];

  home.packages = with pkgs; [
    docs
    afio-font
    (pkgs.writers.writeBashBin "nix-run4" ''
      nix run "$FLAKE#pkgs.$@"
    '')
    stow
    just
    rink
  ];

	programs.helix = {
		enable = true;
		settings = {
      theme = "catppuccin_mocha";
      editor = {
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
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
		};
		extraPackages = with pkgs; [
			marksman
			nixd
			rust-analyzer
			bash-language-server
		];
	};

  programs.bash.enable = lib.mkForce false;
  programs.home-manager.enable = true;
}
# vim:sw=2 ts=2 sts=2

