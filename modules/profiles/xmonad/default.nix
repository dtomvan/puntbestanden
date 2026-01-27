{
  perSystem =
    {
      self',
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
                  alacritty
                  feh
                  self'.packages.myDmenu
                  xmobar
                ]
              ))
            ];
          }
          ''
            import XMonad
            import XMonad.Hooks.StatusBar
            import XMonad.Hooks.StatusBar.PP
            import XMonad.Layout.Spacing
            import XMonad.Util.EZConfig (additionalKeysP)
            import XMonad.Util.SpawnOnce

            myKeys =
              [ ("M-d", spawn "dmenu_run")
              ]

            myStatusBar = statusBarProp "xmobar ${self'.packages.myXmobarrc}" (pure xmobarPP)

            myStartupHook = do
              spawnOnce "feh --bg-fill ${self'.packages.my-wallpaper.passthru.kdeFilePath}"

            -- copied default layout hook for convenience
            myLayoutHook = spacingWithEdge gap $ tiled ||| Mirror tiled ||| Full
              where
                gap     = 4
                tiled   = Tall nmaster delta ratio
                -- The default number of windows in the master pane
                nmaster = 1
                -- Default proportion of screen occupied by master pane
                ratio   = 1/2
                -- Percent of screen to increment by when resizing panes
                delta   = 3/100

            main = xmonad . withEasySB myStatusBar defToggleStrutsKey $ def
              { terminal = "alacritty"
                , modMask = mod4Mask
                , startupHook = myStartupHook
                , layoutHook = myLayoutHook
              }
              `additionalKeysP` myKeys
          '';
    };

  flake.modules.nixos.profiles-xmonad =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    let
      myPkgs = self'.packages;
    in
    {
      services.xserver.enable = true;
      services.xserver.windowManager.session = lib.singleton {
        name = "xmonad";
        start = ''
          systemd-cat -t xmonad -- ${lib.getExe' myPkgs.myXmonad "xmonad-${pkgs.system}"}
          waitPID=$!
        '';
      };
    };
}
