{ pkgs, ... }:
{
  imports = [
    # ./modules/hyprland.nix
    ./modules/utilities.nix
    ./modules/programs/gpg.nix

    ./modules/networking/tailscale.nix

    ./modules/services/keybase.nix
    ./modules/services/syncthing.nix

    ./modules/virt/distrobox.nix
  ];

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

  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  services.lorri.enable = true;

  programs.less.enable = true;
  programs.command-not-found.enable = false;

  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  environment.stub-ld.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "24.11";
}
