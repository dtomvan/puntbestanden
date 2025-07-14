{
  flake.modules.nixos.users-tomvd = {
    nix.settings = {
      trusted-users = [ "tomvd" ];
    };

    users.users.tomvd = {
      isNormalUser = true;
      createHome = true;
      # not sure which are needed but I don't want to debug these again
      extraGroups = [
        "wheel"
        "kvm"
        "audio"
        "seat"
        "libvirtd"
        "qemu-libvirtd"
        "lp"
        "scanner"
        "audio"
        "docker"
      ];

      hashedPassword = "$y$j9T$UNKC2ue19sYmCgHQGWcVE.$.6FqJwASbIV0O7c1hJM7BsPnGV6j98lMzr635nHmwA4";
    };
  };
}
