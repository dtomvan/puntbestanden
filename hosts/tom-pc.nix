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

    # WARN: include a boot loader or you'll just not boot... bummer!
    ../os-modules/boot/systemd-boot.nix
    ../os-modules/boot/plymouth.nix

    ../os-modules/packagesets/utilities/archives.nix
    ../os-modules/packagesets/utilities/build-tools.nix
    ../os-modules/packagesets/utilities/linux.nix
    ../os-modules/packagesets/utilities/nix.nix
    ../os-modules/packagesets/utilities/repos.nix
    ../os-modules/programs/libreoffice.nix
    ../os-modules/programs/gpg.nix

    # networking / bluetooth
    ../os-modules/networking/bluetooth.nix
    ../os-modules/networking/networkmanager.nix
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

    ../os-modules/misc/dutch.nix

    ../os-modules/services/udisks.nix
    ../os-modules/services/printing.nix
    ../os-modules/services/sane.nix
    ../os-modules/services/flatpak.nix
    ../os-modules/services/keybase.nix
    ../os-modules/services/ssh.nix
    ../os-modules/services/syncthing.nix

    ../os-modules/virt/kvm.nix
    ../os-modules/virt/distrobox.nix
  ];

  modules = {
		ssh.enable = true;
    printing.useHPLip = true;
    # gaming-extra.epicGames.enable = true;
  };

  networking.hostName = "tom-pc";
  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    nh
    wl-clipboard

		keepassxc
  ];

	services.displayManager = {
		sddm.enable = false;
		sddm.wayland.enable = false;

		ly.enable = true;
	};

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
