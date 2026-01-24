{
  flake.modules.nixos.virt-distrobox =
    { pkgs, ... }:
    {
      virtualisation.podman.enable = true;
      environment.systemPackages = [ pkgs.distrobox ];
    };
}
