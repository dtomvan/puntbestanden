{pkgs, ...}: {
  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [
      protonup
      gamemode
      mangohud
    ];
    extraCompatPackages = [pkgs.proton-ge-bin];
    # for wayland
    extest.enable = true;
  };
  programs.gamescope = {
    enable = true;
    capSysNice = true;
  };
}
