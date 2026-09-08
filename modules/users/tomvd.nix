{ self, ... }:
{
  flake.modules.nixos.users-tomvd = {
    nix.settings = {
      trusted-users = [ "tomvd" ];
    };

    users.users.tomvd = {
      uid = 1000;
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
        "wpa_supplicant"
      ];

      hashedPassword = "$y$j9T$UNKC2ue19sYmCgHQGWcVE.$.6FqJwASbIV0O7c1hJM7BsPnGV6j98lMzr635nHmwA4";
    };
  };

  users.tomvd = {
    fullName = "Tom Oostveen";
    email = "tomoostveen.06@gmail.com";
    gpgPubKey = "EFD11A9B09D8D2C6";
    locale = "en_US.UTF-8";
    timeZone = "Europe/Amsterdam";
  };

  flake.modules.homeManager.users-tomvd.imports = builtins.attrValues {
    inherit (self.modules.homeManager)
      profiles-base
      basic-cli
      cs-calendars
      ;
  };
}
