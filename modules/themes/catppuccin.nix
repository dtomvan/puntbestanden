{ inputs, lib, ... }:
let
  inherit (lib) getExe mkDefault;
  catppuccin = {
    enable = true;
    autoEnable = false;

    accent = "peach";
    flavor = "mocha";
  };
  colorScheme = "CatppuccinMochaPeach";
in
{
  flake-inputs.catppuccin = {
    url = "github:catppuccin/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.themes-catppuccin = {
    imports = [
      inputs.catppuccin.nixosModules.catppuccin
    ];

    catppuccin = catppuccin // {
      plymouth.enable = true;
      sddm.enable = true;
    };
  };

  flake.modules.homeManager.themes-catppuccin =
    { pkgs, config, ... }:
    let
      catppuccin-kde = pkgs.callPackage ./_catppuccin-kde.nix { inherit colorScheme; };

      inherit (pkgs.nixos-artwork.wallpapers) nineish-catppuccin-mocha;
      wallpaper = nineish-catppuccin-mocha.passthru.kdeFilePath;
    in
    {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

      xdg.dataFile."color-schemes/${colorScheme}.colors" = mkDefault {
        force = true;
        source = catppuccin-kde;
      };

      xdg.dataFile."konsole/${colorScheme}.colorscheme" = mkDefault {
        force = true;
        source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/konsole/3b64040e3f4ae5afb2347e7be8a38bc3cd8c73a8/themes/catppuccin-mocha.colorscheme";
          hash = "sha256-apsWpYLpmBQdbZCNo7h6wXK3eB9HtBkoJ3P3DReAB28=";
        };
      };

      programs.${if config ? programs.plasma then "plasma" else null} = mkDefault {
        workspace = { inherit colorScheme wallpaper; };

        kscreenlocker.appearance = { inherit wallpaper; };
      };

      programs.${if config ? programs.konsole then "konsole" else null} = mkDefault {
        enable = true;
        defaultProfile = "Catppuccin";
        profiles.Catppuccin = {
          inherit colorScheme;
          command = getExe config.programs.bash.finalPackage;
        };
      };

      programs.firefox.profiles.dev-edition-default.extensions = {
        packages = [
          pkgs.nur.repos.rycee.firefox-addons.firefox-color
        ];
        settings."FirefoxColor@mozilla.com" = {
          force = true;
          settings = {
            firstRunDone = true;
            theme = import ./_catppuccin-firefox.nix;
          };
        };
      };

      programs.${if config ? programs.noctalia then "noctalia" else null}.settings = {
        wallpaper.default.path = wallpaper;
        theme.builtin = "Catppuccin";
      };

      catppuccin = catppuccin // {
        alacritty.enable = true;
        bat.enable = true;
        btop.enable = true;
        foot.enable = true;
        ghostty.enable = true;
        glamour.enable = true;
        yazi.enable = true;
        zellij.enable = true;
      };
    };

  flake.modules.nixvim.default.colorschemes.catppuccin = {
    enable = true;
    settings.flavour = catppuccin.flavor; # nice
  };
}
