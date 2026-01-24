let
  family = "Inter";
  fixedWidth = {
    family = "AporeticSansM Nerd Font";
    pointSize = 12;
  };
in
{ lib, ... }:
{
  flake.modules.nixos.fonts =
    {
      pkgs,
      config,
      ...
    }:
    let
      monoFontPackage = pkgs.nur.repos.dtomvan.aporetic-patched;
    in
    {
      fonts = {
        packages = with pkgs; [
          inter
          noto-fonts-color-emoji
          liberation_ttf
          monoFontPackage
        ];

        fontconfig = {
          useEmbeddedBitmaps = true;
          defaultFonts = {
            serif = [ "Liberation Serif" ];
            sansSerif = [ family ];
            monospace = [ fixedWidth.family ];
          };
        };
      };

      # ah yes, very unhardcoded
      boot.loader.grub = {
        font = "${monoFontPackage}/share/fonts/truetype/${
          lib.replaceStrings [ " " ] [ "" ] fixedWidth.family
        }-Regular.ttf";
        fontSize = fixedWidth.pointSize;
      };

      services = {
        ${if config.services ? copyparty then "copyparty" else null} =
          lib.mkIf config.services.copyparty.enable
            {
              settings.html-head =
                lib.replaceStrings [ "\n" ] [ " " ]
                  # html
                  ''
                    <style>
                    :root {
                      --font-main: ${family};
                      --font-serif: ${family};
                      --font-mono: ${fixedWidth.family};
                    }
                    </style>
                  '';
            };
      };
    };

  flake.modules.homeManager.profiles-plasma = {
    programs.plasma = {
      fonts = {
        inherit fixedWidth;
        general = {
          inherit family;
          pointSize = 11;
        };
        menu = {
          inherit family;
          pointSize = 10;
        };
        small = {
          inherit family;
          pointSize = 8;
        };
        toolbar = {
          inherit family;
          pointSize = 10;
        };
      };
    };

    programs.kate.editor.font = fixedWidth;
    programs.konsole.profiles.Catppuccin.font = {
      name = fixedWidth.family;
      size = fixedWidth.pointSize + 2;
    };
  };

  flake.modules.homeManager.terminals = {
    options.modules.terminals = {
      font.family = lib.mkOption {
        description = "the font to use in the terminal";
        default = fixedWidth.family;
        type = lib.types.str;
      };
      font.size = lib.mkOption {
        description = "the font size to use in the terminal";
        default = fixedWidth.pointSize;
        type = lib.types.ints.between 9 30;
      };
    };
  };

  perSystem =
    { pkgs, ... }:
    {
      packages.quickshellConfig = pkgs.replaceVars ./profiles/hyprland/shell.qml {
        inherit (fixedWidth) family pointSize;
        DEFAULT_AUDIO_SINK = null;
      };
      packages.myXmobarrc = pkgs.replaceVars ./profiles/xmonad/xmobarrc {
        inherit (fixedWidth) family;
        size = fixedWidth.pointSize;
      };
    };
}
