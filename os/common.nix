{
  host,
  lib,
  nixConfig,
  ...
}:
{
  nixpkgs.flake.setFlakeRegistry = true;
  nix = {
    settings = {
      experimental-features = lib.mkDefault [
        "nix-command"
        "flakes"
      ];
    } // nixConfig;
    channel.enable = false;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
    optimise = {
      automatic = true;
    };
  };

  services.journald.extraConfig = ''
    SystemMaxUse=250M
    SystemMaxFileSize=50M
  '';

  hardware.cpu.${host.hardware.cpuVendor}.updateMicrocode = true;

  networking = {
    inherit (host) hostName;
    networkmanager.enable = true;
  };

  sops.age.sshKeyPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/tomvd/.ssh/id_ed25519"
  ];
}
