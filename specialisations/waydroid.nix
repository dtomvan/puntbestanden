{pkgs, ...}: {
  specialisation.waydroid.configuration = {
    environment.systemPackages = [pkgs.wl-clipboard];
    virtualisation.waydroid.enable = true;
  };
}
