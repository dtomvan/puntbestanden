{
  flake.modules.homeManager.hyprland =
    { pkgs, ... }:
    {
      services.hyprpaper =
        let
          wallpaper = pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha.passthru.kdeFilePath;
        in
        {
          enable = true;
          settings = {
            ipc = "on";
            preload = [
              "${wallpaper}"
            ];
            wallpaper = [
              "DP-1,${wallpaper}"
              "eDP-1,${wallpaper}"
            ];
          };
        };

    };
}
