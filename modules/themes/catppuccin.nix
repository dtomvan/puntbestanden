{ inputs, ... }:
let
  catppuccin = {
    accent = "peach";
    flavor = "mocha";
  };
  colorScheme = "CatppuccinMochaPeach";
in
{
  nixConfig = {
    extra-substituters = [ "https://catppuccin.cachix.org" ];
    extra-trusted-public-keys = [
      "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="
    ];
  };

  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.themes-catppuccin = {
    imports = [
      inputs.catppuccin.nixosModules.catppuccin
    ];

    catppuccin = catppuccin // {
      sddm.enable = true;
    };
  };

  flake.modules.homeManager.themes-catppuccin =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      catppuccin-kde = pkgs.callPackage (
        { stdenvNoCC, fetchFromGitHub }:
        stdenvNoCC.mkDerivation (finalAttrs: {
          pname = "catppuccin-kde";
          version = "0.2.6";

          src = fetchFromGitHub {
            owner = "catppuccin";
            repo = "kde";
            tag = "v${finalAttrs.version}";
            hash = "sha256-pfG0L4eSXLYLZM8Mhla4yalpEro74S9kc0sOmQtnG3w=";
          };

          postPatch = ''
            chmod +x **.sh
            patchShebangs .
            # we will not be using wget, unzip, or lookandfeeltool, so I won't
            # put it in the closure.
            sed -Ei -e '/^check_command_exists ".*"$/d' install.sh
          '';

          installPhase = ''
            runHook preInstall
              # mocha, peach, default decorations, only build colorscheme
              ./install.sh 1 7 1 color
              install -m644 ./dist/${colorScheme}.colors $out
            runHook postInstall
          '';
        })
      ) { };
    in
    {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

      xdg.dataFile."color-schemes/${colorScheme}.colors" = {
        force = true;
        source = catppuccin-kde;
      };

      xdg.dataFile."konsole/${colorScheme}.colorscheme" = {
        force = true;
        source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/konsole/3b64040e3f4ae5afb2347e7be8a38bc3cd8c73a8/themes/catppuccin-mocha.colorscheme";
          hash = "sha256-apsWpYLpmBQdbZCNo7h6wXK3eB9HtBkoJ3P3DReAB28=";
        };
      };

      programs.${if config.programs ? plasma then "plasma" else null} = {
        workspace = { inherit colorScheme; };
      };

      programs.${if config.programs ? konsole then "konsole" else null} = {
        enable = true;
        defaultProfile = "Catppuccin";
        profiles.Catppuccin = {
          inherit colorScheme;
          command = "${lib.getExe pkgs.bashInteractive}";
        };
      };

      programs.firefox.profiles.default.extensions.packages = [
        pkgs.nur.repos.rycee.firefox-addons.firefox-color
      ];

      catppuccin = catppuccin // {
        alacritty.enable = true;
        bat.enable = true;
        btop.enable = true;
        firefox = {
          enable = true;
          profiles.default.enable = true;
        };
        ghostty.enable = true;
        glamour.enable = true;
        helix.enable = true;
        skim.enable = true;
        yazi.enable = true;
        zellij.enable = true;
      };
    };

  flake.modules.nixvim.default.colorschemes.catppuccin = {
    enable = true;
    settings.flavour = catppuccin.flavor; # nice
  };
}
