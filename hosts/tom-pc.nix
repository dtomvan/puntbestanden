{
  pkgs,
  config,
  lib,
  ...
}: {
  nix.settings = {
    trusted-users = ["tomvd"];
  };
  imports = [
    # nix and nixpkgs config
    ../os-modules/maintenance.nix
    ../os-modules/nix-config-common.nix
    ../os-modules/substituters/hyprland.nix

    # hardware / drivers
    ../hardware/tom-pc.nix
    ../os-modules/hardware/nvidia.nix
    ../os-modules/hardware/ssd.nix
    ../os-modules/misc/udisks.nix

    # package sets (groups of packages that I want to
    # reuse across installs, to hopefully future-proof
    # my nixos configuration
    ../os-modules/packagesets/archives.nix
    ../os-modules/packagesets/build-tools.nix
    ../os-modules/packagesets/nix-helpers.nix
    ../os-modules/packagesets/nix-tools.nix
    ../os-modules/packagesets/repo-tools.nix
    ../os-modules/packagesets/linux-utils.nix

# Docker
    # ../os-modules/packagesets/docker.nix

    # networking / bluetooth
    ../os-modules/networking/bluetooth.nix
    # ../os-modules/networking/static-ip.nix
    ../os-modules/networking/iwd.nix
    ../os-modules/networking/tailscale.nix

    # Users (no home-manager, built separately)
    # WARNING: users.mutableUsers == false, so removing all regular users renders
    # the system almost UNUSABLE. Remove users with caution (obviously).
    ../os-modules/users/tomvd.nix

    # Experimenting with "old" environments (nextstep design/ux)
    # ../os-modules/xorg.nix

    # Big programs / configuration
    ../os-modules/steam.nix
    ../os-modules/graphical-session.nix
    ../os-modules/printing.nix
    ../os-modules/gaming-extra.nix
    ../os-modules/syncthing.nix

    ../specialisations/waydroid.nix
  ];

  modules = {
    printing.useHPLip = true;
    gaming-extra.epicGames.enable = true;
    syncthing.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tom-pc";
  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    nh
    # nixos-rebuild
    iwd
    wl-clipboard

		distrobox
  ];

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # WARNING: this requires a user to be set, or the root password to be known.
  users.mutableUsers = false;

  services.keybase.enable = true;
  services.kbfs.enable = true;
  services.flatpak.enable = true;

  security.polkit.enable = true;
  environment.etc."libvirt/qemu.conf".text = "group=kvm";
  virtualisation.waydroid.enable = true;
  users.groups.libvirtd.members = ["tomvd"];
  virtualisation.spiceUSBRedirection.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
      ovmf = {
        enable = true;
        packages = [
          (pkgs.OVMF.override {
            secureBoot = true;
            tpmSupport = true;
          })
          .fd
        ];
      };
    };
  };
  programs.virt-manager.enable = true;

	virtualisation.podman = {
		enable = true;
		dockerCompat = true;
	};

  services.lorri.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  programs.less.enable = true;
  programs.command-not-found.enable = false;

  environment.stub-ld.enable = false;
  networking.firewall.enable = false;

  system.stateVersion = "24.05";
}
