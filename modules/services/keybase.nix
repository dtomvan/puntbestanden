{
  flake.modules.nixos.services-keybase = {
    services = {
      keybase.enable = true;
      kbfs.enable = true;
    };

    systemd.user.services = {
      keybase.enable = false;
      kbfs.enable = false;
    };
  };
}
