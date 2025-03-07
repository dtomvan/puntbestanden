{pkgs, ...}: {
  imports = [
    # nix and nixpkgs config
    ./modules/maintenance.nix
    ./modules/nix-config-common.nix

    # hardware / drivers
    ./hardware/tom-pc.nix
    ./hardware/nvidia.nix
    ./hardware/ssd.nix
    ./hardware/sound.nix

    # WARN: include a boot loader or you'll just not boot... bummer!
    ./modules/boot/systemd-boot.nix
    ./modules/boot/plymouth.nix

    ./modules/utilities.nix
    ./modules/programs/libreoffice.nix
    ./modules/programs/gpg.nix

    # networking / bluetooth
    ./modules/networking/bluetooth.nix
    ./modules/networking/networkmanager.nix
    ./modules/networking/tailscale.nix

    # Users (no home-manager, built separately)
    # WARNING: users.mutableUsers == false, so removing all regular users renders
    # the system almost UNUSABLE. Remove users with caution (obviously).
    ./modules/users/tomvd.nix
    ./modules/users/root.nix

    # Big programs / configuration
    ./modules/gaming/steam.nix
    ./modules/gaming/gaming-extra.nix

    ./modules/kde.nix

    ./modules/misc/dutch.nix

    ./modules/services/printing.nix
    ./modules/services/sane.nix
    ./modules/services/flatpak.nix
    ./modules/services/keybase.nix
    ./modules/services/ssh.nix
    ./modules/services/syncthing.nix

    ./modules/virt/kvm.nix
    ./modules/virt/distrobox.nix
  ];

  modules = {
		ssh.enable = true;
    printing.useHPLip = true;
    # gaming-extra.epicGames.enable = true;

    utilities = {
      archives = true;
      build-tools = true;
      linux = true;
      nix = true;
      repos = true;
    };
  };

  networking.hostName = "tom-pc";
  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    nh
    wl-clipboard

		keepassxc
    # fuck flatpaks they don't even work half the time
    discord
    localsend
    thunderbird
    gimp
    obsidian
    haruna
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
