{pkgs, ...}: {
  imports = [
    ./modules/utilities.nix
    ./modules/programs/gpg.nix

    ./modules/networking/tailscale.nix

    ./modules/gaming/steam.nix

    ./modules/services/keybase.nix
    ./modules/services/syncthing.nix

    ./modules/virt/kvm.nix
    ./modules/virt/distrobox.nix
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

    utilities = {
      archives = true;
      build-tools = true;
      linux = true;
      nix = true;
      repos = true;
    };
  };

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    nh
    wl-clipboard
    libreoffice-qt6-fresh

    keepassxc
    zotero
    # fuck flatpaks they don't even work half the time
    discord
    localsend
    thunderbird
    gimp
    obsidian

    prismlauncher

    python3
  ];

  # services.displayManager = {
  #   sddm.enable = false;
  #   sddm.wayland.enable = false;
  #
  #   ly.enable = true;
  # };

  hardware.bluetooth.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  # WARNING: this requires a user to be set, or the root password to be known.
  users.mutableUsers = false;

  virtualisation.waydroid.enable = true;

  services.lorri.enable = true;

  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  programs.less.enable = true;
  programs.command-not-found.enable = false;

  environment.stub-ld.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "24.05";
}
