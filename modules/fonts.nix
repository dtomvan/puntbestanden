let
  family = "Inter";
  fixedWidth = {
    family = "afio";
    pointSize = 12;
  };
in
{
  flake.modules.nixos.fonts =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      fonts = {
        packages = with pkgs; [
          inter
          noto-fonts-color-emoji
          liberation_ttf
          nur.repos.dtomvan.afio-font-bin
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

      services.copyparty = lib.mkIf config.services.copyparty.enable {
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

  flake.modules.homeManager.plasma = {
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

    modules.terminals.font = {
      inherit (fixedWidth) family;
      size = fixedWidth.pointSize;
    };
  };
}
