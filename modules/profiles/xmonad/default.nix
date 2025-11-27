{ self, ... }:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    {
      # trick to un-nixosify the xmonad binary builder. in theory we could go
      # to ubuntu, nix build this package and run xmonad like that. freedom or
      # something </rant>
      packages.myXmonad =
        pkgs.writers.writeHaskellBin "xmonad-${system}"
          {
            libraries = with pkgs.haskellPackages; [
              xmonad
              xmonad-contrib
              xmonad-extras
            ];
            makeWrapperArgs = [
              "--prefix"
              "PATH"
              ":"
              (lib.makeBinPath (
                with pkgs;
                [
                  myDmenu
                  myEmacs
                  xmobar
                  alacritty
                  picom
                ]
              ))
            ];
          }
          ''
            import XMonad
            import XMonad.Hooks.StatusBar
            import XMonad.Hooks.StatusBar.PP
            import XMonad.Util.EZConfig (additionalKeysP)
            import XMonad.Util.SpawnOnce

            myKeys =
              [ ("M-D", spawn "dmenu_run")
              ]

            myStatusBar = statusBarProp "xmobar ${pkgs.myXmobarrc}" (pure xmobarPP)

            myStartupHook = do
              spawnOnce "feh --bg-fill ${pkgs.my-wallpaper.passthru.kdeFilePath}"
              spawnOnce "picom"
              spawnOnce "emacs"

            main = xmonad . withEasySB myStatusBar defToggleStrutsKey $ def
              { terminal = "alacritty"
                , modMask = mod1Mask
                , startupHook = myStartupHook
              }
              `additionalKeysP` myKeys
          '';

      packages.myDmenu = pkgs.dmenu.override {
        conf =
          # c
          ''
            static int topbar = 1;
            static int fuzzy  = 1;
            static const char *fonts[] = {
              "monospace:size=12"
            };
            static const char *prompt = NULL;
            static const char *colors[SchemeLast][2] = {
              [SchemeNorm] = { "#ebdbb2", "#282828" },
              [SchemeSel] = { "#ebdbb2", "#98971a" },
              [SchemeOut] = { "#ebdbb2", "#8ec07c" },
            };
            static unsigned int lines = 0;
            static const char worddelimiters[] = " ";
          '';
        patches = [
          (pkgs.fetchpatch2 {
            url = "https://tools.suckless.org/dmenu/patches/fuzzymatch/dmenu-fuzzymatch-5.3.diff";
            hash = "sha256-GaKjI4pGf7PRMh4VJE6l/jQK99fW8YU5ZGpgjktzaic=";
          })
        ];
      };
    };

  flake.modules.nixos.profiles-xmonad =
    { pkgs, lib, ... }:
    {
      imports = [ self.modules.nixos.profiles-ly ];
      services.xserver = {
        enable = true;
        session = [
          {
            name = "xmonad";
            start = ''
              systemd-cat -t xmonad -- ${lib.getExe' pkgs.myXmonad "xmonad-${pkgs.stdenv.hostPlatform.system}"}
              waitPID=$!
            '';
          }
        ];
      };
    };
}
