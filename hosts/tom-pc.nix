{pkgs, ...}: {
  imports = [
    # nix and nixpkgs config
    ../os-modules/maintenance.nix
    ../os-modules/nix-config-common.nix

    # hardware / drivers
    ../hardware/tom-pc.nix
    ../os-modules/hardware/nvidia.nix
    ../os-modules/hardware/ssd.nix
    ../os-modules/hardware/sound.nix
    ../os-modules/misc/udisks.nix

    # WARN: include a boot loader or you'll just not boot... bummer!
    ../os-modules/boot/systemd-boot.nix


    ../os-modules/packagesets/utilities/archives.nix
    ../os-modules/packagesets/utilities/build-tools.nix
    ../os-modules/packagesets/utilities/linux.nix
    ../os-modules/packagesets/utilities/nix.nix
    ../os-modules/packagesets/utilities/repos.nix
    ../os-modules/programs/libreoffice.nix

    # networking / bluetooth
    ../os-modules/networking/bluetooth.nix
    # ../os-modules/networking/networkmanager.nix
    ../os-modules/networking/tailscale.nix

    # Users (no home-manager, built separately)
    # WARNING: users.mutableUsers == false, so removing all regular users renders
    # the system almost UNUSABLE. Remove users with caution (obviously).
    ../os-modules/users/tomvd.nix
    ../os-modules/users/root.nix

    # Big programs / configuration
    ../os-modules/gaming/steam.nix
    ../os-modules/gaming/gaming-extra.nix

    ../os-modules/kde.nix

    ../os-modules/misc/printing.nix
    ../os-modules/misc/flatpak.nix
    ../os-modules/misc/gpg.nix
    ../os-modules/misc/keybase.nix

    ../os-modules/virt/kvm.nix
    ../os-modules/virt/distrobox.nix
  ];

  modules = {
    # printing.useHPLip = true;
    # gaming-extra.epicGames.enable = true;
  };

  networking.hostName = "tom-pc";
  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    nh
    wl-clipboard
  ];

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  # WARNING: this requires a user to be set, or the root password to be known.
  users.mutableUsers = false;

  virtualisation.waydroid.enable = true;

  services.lorri.enable = true;

  programs.less.enable = true;
  programs.command-not-found.enable = false;

  environment.stub-ld.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "24.05";
}
