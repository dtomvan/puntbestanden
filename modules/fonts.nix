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
        packages = builtins.attrValues {
          inherit (pkgs)
            inter
            liberation_ttf
            noto-fonts-color-emoji
            ;
          inherit monoFontPackage;
        };

        fontconfig = {
          useEmbeddedBitmaps = true;
          defaultFonts = {
            serif = [ "Liberation Serif" ];
            sansSerif = [ family ];
            monospace = [ fixedWidth.family ];
          };
        };
      };

      services.kmscon.config = {
        font-name = fixedWidth.family;
        font-size = fixedWidth.pointSize;
      };

      services = {
        ${if config ? services.copyparty then "copyparty" else null} =
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

      services.displayManager.regreet.font.name = family;
    };

  flake.modules.maid.profiles-plasma.kconfig.settings.kdeglobals.General = {
    fixed = "${fixedWidth.family},${toString fixedWidth.pointSize},-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
    font = "${family},11,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
    menuFont = "${family},10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
    smallestReadableFont = "${family},8,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
    toolBarFont = "${family},10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1";
  };

  flake.modules.homeManager.profiles-graphical.gtk.font.name = family;

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
}
