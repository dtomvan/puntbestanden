{
  flake.modules.nixos.virt-podman =
    { pkgs, ... }:
    {
      virtualisation.podman.enable = true;
      environment.systemPackages = builtins.attrValues {
        inherit (pkgs)
          distrobox
          podman-compose
          ;
      };
    };
}
