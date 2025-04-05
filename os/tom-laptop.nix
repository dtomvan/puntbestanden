{pkgs, ...}: {
  imports = [
    # nix and nixpkgs config
    ./modules/maintenance.nix
    ./modules/nix-config-common.nix

    ./modules/fonts.nix

    # hardware / drivers
    ./hardware/tom-laptop.nix
    ./hardware/sound.nix
    ./hardware/ssd.nix
		./hardware/elan-tp.nix
		./hardware/comet-lake.nix

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

    ./modules/kde.nix

    ./modules/services/ssh.nix
    ./modules/services/printing.nix
    ./modules/services/flatpak.nix
    ./modules/services/keybase.nix
    ./modules/services/syncthing.nix

    ./modules/misc/dutch.nix

    ./modules/virt/distrobox.nix
  ];

  modules = {
		ssh.enable = true;
    printing.useHPLip = true;
		boot.plymouth.enable = true;

    utilities = {
      archives = true;
      build-tools = true;
      linux = true;
      nix = true;
      repos = true;
    };
  };

	services.displayManager.sddm.settings = {
		AutoLogin = {
			Session = "plasma.desktop";
			User = "tomvd";
		};
	};

  networking.hostName = "tom-laptop";
  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    nh
    wl-clipboard
		git
    nixos-artwork.wallpapers.catppuccin-mocha

		keepassxc
    clj-bins
  ];

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
