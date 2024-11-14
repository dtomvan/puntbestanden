{ pkgs, config, lib, ... }:
{
	nixpkgs.config.allowUnfree = true;
    nix.settings = {
		trusted-users = [ "tomvd" ];
        experimental-features = [ "nix-command" "flakes" ];
        substituters = [
		"https://hyprland.cachix.org"
		"https://cosmic.cachix.org"
		];
        trusted-public-keys = [
		"hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
		"cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
		];
    };
    imports = [
        ../hardware/tom-pc.nix
    ];

	environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;
	boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
   boot.loader.systemd-boot.enable = true;
   boot.loader.efi.canTouchEfiVariables = true;

    networking.hostName = "tom-pc";
	networking.networkmanager.wifi.backend = "iwd";
    networking.wireless.iwd.enable = true;
    networking.dhcpcd.enable = true;
	networking.dhcpcd.extraConfig = ''
	interface wlan0
	static ip_address=192.168.2.33/24
	static routers=192.168.2.254
	'';
    networking.wireless.enable = false;
	hardware.bluetooth.enable = true;
	services.blueman.enable = true;

    time.timeZone = "Europe/Amsterdam";
    i18n.defaultLocale = "en_US.UTF-8";

	services.xserver.videoDrivers = [ "nvidia" ];
	hardware.graphics = {
		enable = true;
		enable32Bit = true;
	};
	hardware.nvidia = {
		modesetting.enable = true;
		powerManagement.enable = false;
		powerManagement.finegrained = false;
		open = false;
		nvidiaSettings = true;
		package = config.boot.kernelPackages.nvidiaPackages.stable;
	  };

	services.fstrim.enable = true;
    services.pipewire = {
        enable = true;
        pulse.enable = true;
    };

    users.mutableUsers = false;
    users.users.tomvd = {
        isNormalUser = true;
        createHome = true;
		shell = pkgs.zsh;
        # not sure which are needed but I don't want to debug these again
        extraGroups = [ "wheel" "kvm" "audio" "seat" "libvirtd" "lp" "audio" ];
# Packages that I always want available, no matter if I have home-manager installed
        packages = with pkgs; [
            firefox
            neovim
            btop
            du-dust
            eza
            fd
            jq
            ripgrep
            zathura
# Can't decide on an image viewer...
			sxiv
			pqiv
			wl-clipboard
			pavucontrol
			alsa-utils
			nix-tree
			mpv
        ];
        hashedPassword = "$6$H7z49YyQ3UJkW5rC$C.EWZnpCX9c1/OJPB.sbq9iqFbEwrHYsm2Whn5GbJJPsu05VFWo3V71sxUydb9rhLjDUB.pqVwiESolfOORID0";
    };
	programs.zsh.enable = true;
	# services.displayManager.cosmic-greeter.enable = true;
	# services.desktopManager.cosmic.enable = true;
    programs.hyprland = {
        enable = true;
        package = pkgs.hyprland;
        portalPackage = pkgs.xdg-desktop-portal-hyprland;
    };
    programs.neovim.defaultEditor = true;
    xdg.portal.wlr.enable = true;
    xdg.portal.extraPortals = with pkgs; [
		xdg-desktop-portal-hyprland 
		xdg-desktop-portal-gtk
	];
	services.printing = {
		enable = true;
		drivers = [ pkgs.hplip ];
	};
	services.system-config-printer.enable = true;
	programs.system-config-printer.enable = true;

    services.greetd.enable = true;
    services.greetd.settings.default_session = {
        command = "${pkgs.greetd.greetd}/bin/agreety --cmd Hyprland";
    };
    services.keybase.enable = true;
    services.kbfs.enable = true;
    services.flatpak.enable = true;

	security.polkit.enable = true;
	virtualisation.libvirtd.enable = true;
	virtualisation.libvirtd.qemu.package = pkgs.qemu_kvm;
	programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
        home-manager
        wget
        curl
        nixos-rebuild
		iwd

		gcc
		pkg-config
		gnumake
		cmake
		meson

# General archive support
		unzip
		zip
		libarchive
		rar
		unrar
		bzip2
		lz4
# Ooh spooky
		xz

# Nix helpers
		nh
		nix-fast-build
		nix-output-monitor
		nvd
    ];

	programs.steam = {
		enable = true;
		extraPackages = with pkgs; [
		protonup
		gamemode
		mangohud
		];
		extraCompatPackages = [pkgs.proton-ge-bin];
# for wayland
		extest.enable = true;
	};
	programs.gamescope = {
		enable = true;
		capSysNice = true;
	};

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
