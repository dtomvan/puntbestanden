{
  pkgs,
  lib,
  ...
}: {
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [
      protonup
      gamemode
      mangohud
    ];
    # extraCompatPackages = [pkgs.proton-ge-bin];
    # for wayland
    extest.enable = lib.mkDefault true;
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
}
