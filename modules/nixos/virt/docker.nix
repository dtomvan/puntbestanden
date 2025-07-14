{
  flake.modules.nixos.virt-docker = {
    virtualisation.docker = {
      enable = true;
    };
  };
}
