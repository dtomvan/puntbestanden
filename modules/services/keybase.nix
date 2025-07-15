{
  flake.modules.nixos.services-keybase = {
    services = {
      keybase.enable = true;
      kbfs.enable = true;
    };
  };
}
