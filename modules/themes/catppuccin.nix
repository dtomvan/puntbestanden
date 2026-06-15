{ inputs, ... }:
let
  catppuccin = {
    enable = true;
    autoEnable = false;

    accent = "peach";
    flavor = "mocha";
  };
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
    { pkgs, ... }:
    {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

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

  flake.modules.maid.themes-catppuccin =
    { config, pkgs, ... }:
    let
      colorScheme = "CatppuccinMochaPeach";
      catppuccin-kde = pkgs.callPackage ./_catppuccin-kde.nix { inherit colorScheme; };
      inherit (pkgs.nixos-artwork.wallpapers) nineish-catppuccin-mocha;
      wallpaper = nineish-catppuccin-mocha.passthru.kdeFilePath;
    in
    {
      kconfig = { inherit colorScheme wallpaper; };

      file.xdg_data."color-schemes/${colorScheme}.colors".source = catppuccin-kde;

      programs.${if config ? programs.noctalia then "noctalia" else null}.settings = {
        wallpaper.default.path = wallpaper;
        theme.builtin = "Catppuccin";
      };
    };

  flake.modules.nixvim.default.colorschemes.catppuccin = {
    enable = true;
    settings.flavour = catppuccin.flavor; # nice
  };
}
