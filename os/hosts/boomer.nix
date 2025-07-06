{ inputs, pkgs, ... }:
{
  imports = [
    # TEMP
    # ../modules/hyprland.nix

    ../modules/vintagestory.nix

    ../modules/utilities.nix
    ../modules/programs/gpg.nix

    ../modules/networking/tailscale.nix

    ../modules/gaming/steam.nix

    ../modules/services/keybase.nix
    ../modules/services/syncthing.nix

    ../modules/virt/kvm.nix
    ../modules/virt/distrobox.nix
    ../modules/virt/docker.nix
  ];

  _module.args.nixinate = {
    host = "boomer";
    sshUser = "tomvd";
    buildOn = "remote";
    substituteOnTarget = true;
    hermetic = false;
  };

  modules = {
    printing.useHPLip = true;
  };

  services.localsend-rs.enable = true;

  environment.systemPackages =
    with pkgs;
    [
      home-manager
      wget
      curl
      nh
      wl-clipboard
      libreoffice-qt6-fresh

      keepassxc
      # fuck flatpaks they don't even work half the time
      discord
      thunderbird
      obsidian

      (prismlauncher.override {
        jdks = [
          jdk8
          jdk17
          jdk21
          jdk24
        ];
      })

      logseq

      python3

      nur.repos.dtomvan.tsodingPackages.blang
      nur.repos.dtomvan.tsodingPackages.musializer
      nur.repos.dtomvan.tsodingPackages.fourat
      nur.repos.dtomvan.tsodingPackages.sowon
    ]
    ++ lib.map (pkg: lazy-app.override { inherit pkg; }) [
      # rarely used
      zotero
      localsend
      gimp
    ];

  # hyprland.nix provides regreet, kde.nix provides sddm, choice made.
  # services.displayManager = {
  #   sddm.enable = false;
  #   sddm.wayland.enable = false;
  # };

  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  # WARNING: this requires a user to be set, or the root password to be known.
  users.mutableUsers = false;

  # this doesn't really aid nixpkgs contribution at all
  # programs.nix-ld.enable = true;
  # services.envfs.enable = true;

  programs.less.enable = true;
  programs.command-not-found.enable = false;

  environment.stub-ld.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "24.05";
}
