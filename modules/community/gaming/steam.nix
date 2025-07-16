# This module enables steam with some sensible defaults. If you are not using
# wayland+steam input, please disable `programs.steam.extest.enable` again.
{
  flake.modules.nixos.steam =
    {
      pkgs,
      lib,
      ...
    }:
    {
      programs.steam = {
        enable = true;
        extraPackages = with pkgs; [
          gamemode
          mangohud
        ];
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        # for wayland
        extest.enable = lib.mkDefault true;
      };
      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };
    };
}
