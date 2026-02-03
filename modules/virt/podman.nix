{
  flake.modules.nixos.virt-podman =
    { pkgs, ... }:
    {
      virtualisation.podman.enable = true;
      environment.systemPackages = with pkgs; [
        distrobox
        podman-compose
      ];
    };
}
