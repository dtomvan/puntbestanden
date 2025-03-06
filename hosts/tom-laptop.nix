{pkgs, ...}: {
  imports = [
    # nix and nixpkgs config
    ../os-modules/maintenance.nix
    ../os-modules/nix-config-common.nix

    # hardware / drivers
    ../hardware/tom-laptop.nix
    ../os-modules/hardware/sound.nix
    ../os-modules/hardware/ssd.nix
		../os-modules/hardware/elan-tp.nix
		../os-modules/hardware/comet-lake.nix

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

    ../os-modules/kde.nix

    ../os-modules/services/ssh.nix
    ../os-modules/services/printing.nix
    ../os-modules/services/flatpak.nix
    ../os-modules/services/keybase.nix

    ../os-modules/misc/dutch.nix

    ../os-modules/virt/distrobox.nix
  ];

  modules = {
		ssh.enable = true;
    printing.useHPLip = true;
		boot.plymouth.enable = true;
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

		keepassxc
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
