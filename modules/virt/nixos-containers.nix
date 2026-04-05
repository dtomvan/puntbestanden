{
  flake.modules.nixos.virt-nixos-containers = {
    boot.enableContainers = true;
    virtualisation.containers.enable = true;
  };
}
