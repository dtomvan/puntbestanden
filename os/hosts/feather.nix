{ pkgs, lib, ... }:
{
  imports = [
    # ../modules/hyprland.nix
    ../modules/utilities.nix
    ../modules/programs/gpg.nix

    ../modules/networking/tailscale.nix

    ../modules/services/keybase.nix
    ../modules/services/syncthing.nix

    ../modules/virt/kvm.nix
    ../modules/virt/distrobox.nix
    ../modules/virt/docker.nix
  ];

  virtualisation.libvirtd.onBoot = "ignore";

  # services.localsend-rs.sopsBootstrap = true;

  _module.args.nixinate = {
    host = "feather";
    sshUser = "tomvd";
    buildOn = "local";
    substituteOnTarget = true;
    hermetic = false;
  };

  modules = {
    printing.useHPLip = true;
  };

  environment.systemPackages =
    with pkgs;
    [
      home-manager
      wget
      curl
      nh
      wl-clipboard
      git

      keepassxc
    ]
    ++ lib.map (pkg: lazy-app.override { inherit pkg; }) [
      # rarely used
      libreoffice-qt6-fresh
    ];

  systemd.services.podman.wantedBy = lib.mkForce [ ];
  virtualisation.docker.enableOnBoot = false;

  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  services.lorri.enable = true;

  programs.less.enable = true;
  programs.command-not-found.enable = false;

  environment.stub-ld.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "24.11";
}
