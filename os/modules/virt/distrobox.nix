{pkgs, ...}: {
  virtualisation.podman = { enable = true; };
  environment.systemPackages = [pkgs.distrobox];
}
