{ pkgs, lib, ... }:
{
  imports = [
    ../modules/utilities.nix
    ../modules/programs/gpg.nix

    ../modules/gaming/steam.nix

    ../modules/networking/tailscale.nix

    ../modules/services/keybase.nix
    ../modules/services/syncthing.nix

    ../modules/virt/kvm.nix
    ../modules/virt/distrobox.nix
    ../modules/virt/docker.nix
  ];

  _module.args.nixinate = {
    host = "feather";
    sshUser = "tomvd";
    buildOn = "local";
    substituteOnTarget = true;
    hermetic = false;
  };

  modules = {
    printing.useHPLip = true;
    utilities.enableLazyApps = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      keepassxc
    ]
    ++ lib.map (pkg: lazy-app.override { inherit pkg; }) [
      # rarely used
      libreoffice-qt6-fresh
    ];

  virtualisation.libvirtd.onBoot = "ignore";
  systemd.services.podman.wantedBy = lib.mkForce [ ];
  virtualisation.docker.enableOnBoot = false;

  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.less.enable = true;

  environment.stub-ld.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "24.11";
}
