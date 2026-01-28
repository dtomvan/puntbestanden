{
  # STUB. so that the import scheme is consistent and doesn't error out when added
  flake.modules.nixos.themes-tony = { };

  flake.modules.homeManager.themes-tony =
    {
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = with pkgs; [
        alacritty
        fastfetchMinimal
        nerd-fonts.jetbrains-mono
      ];

      xdg.configFile."rofi/config.rasi".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/tonybanters/tonarchy/ad5c4629263d5c5e84495dd14e1372411af8a5ed/assets/rofi/config.rasi";
        hash = "sha256-GPhGRnJEh1BOUrLcBDMirH+R2kOdomFJajVLEfoIWyU=";
      };

      xdg.configFile."rofi/tokyonight.rasi".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/tonybanters/tonarchy/ffefce2b2fba48fc7d494978472811282e4a4678/assets/rofi/tokyonight.rasi";
        hash = "sha256-hIMkHzPxc5kmjf/TkkAB+/nr9pDwpJM+36oRXKvrbZo=";
      };

      modules.terminals.font.family = lib.mkForce "JetBrainsMono Nerd Font Propo";

      gtk = {
        colorScheme = "dark";
        iconTheme = {
          name = "Papirus-Dark";
          package = pkgs.papirus-icon-theme;
        };
        theme = {
          name = "Tokyonight-Dark";
          package = pkgs.tokyonight-gtk-theme;
        };
      };

      # tokyo night dark
      programs.alacritty.settings.colors = lib.mkForce {
        bright = {
          black = "#444b6a";
          blue = "#7da6ff";
          cyan = "#0db9d7";
          green = "#b9f27c";
          magenta = "#bb9af7";
          red = "#ff7a93";
          white = "#acb0d0";
          yellow = "#ff9e64";
        };
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
        normal = {
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };
      };

      # obligatory
      programs.bash.initExtra = lib.mkAfter ''
        fastfetch
      '';
    };
}
