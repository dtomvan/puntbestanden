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

  perSystem =
    { pkgs, ... }:
    {
      packages.my-wallpaper = pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha;
    };

  flake-file.inputs.catppuccin = {
    url = "github:catppuccin/nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.nixos.themes-catppuccin =
    {
      self',
      lib,
      config,
      ...
    }:
    let
      myPkgs = self'.packages;
    in
    {
      imports = [
        inputs.catppuccin.nixosModules.catppuccin
      ];

      inherit catppuccin;

      boot = {
        # manually re-implement catppuccin module because I want control of mkOverride calls
        plymouth = {
          theme = lib.mkOverride 999 "catppuccin-${config.catppuccin.flavor}";
          themePackages = lib.mkOverride 999 [ "${config.catppuccin.sources.plymouth}" ];
        };
        loader.grub = {
          theme = lib.mkDefault "${config.catppuccin.sources.grub}/share/grub/themes/catppuccin-${config.catppuccin.flavor}-grub-theme";
          splashImage = lib.mkOverride 999 myPkgs.my-wallpaper.passthru.kdeFilePath;
        };
      };
    };

  flake.modules.homeManager.themes-catppuccin =
    {
      self',
      pkgs,
      lib,
      config,
      ...
    }:
    let
      myPkgs = self'.packages;

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

      wallpaper = myPkgs.my-wallpaper.passthru.kdeFilePath;
    in
    {
      imports = [
        inputs.catppuccin.homeModules.catppuccin
      ];

      xdg.dataFile."color-schemes/${colorScheme}.colors" = lib.mkDefault {
        force = true;
        source = catppuccin-kde;
      };

      xdg.dataFile."konsole/${colorScheme}.colorscheme" = lib.mkDefault {
        force = true;
        source = pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/catppuccin/konsole/3b64040e3f4ae5afb2347e7be8a38bc3cd8c73a8/themes/catppuccin-mocha.colorscheme";
          hash = "sha256-apsWpYLpmBQdbZCNo7h6wXK3eB9HtBkoJ3P3DReAB28=";
        };
      };

      programs.${if config.programs ? plasma then "plasma" else null} = {
        workspace = { inherit colorScheme wallpaper; };

        kscreenlocker.appearance = { inherit wallpaper; };
      };

      programs.${if config.programs ? konsole then "konsole" else null} = lib.mkDefault {
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
