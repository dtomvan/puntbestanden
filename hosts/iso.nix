{
  pkgs,
  config,
  lib,
  modulesPath,
  ...
}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
  };
  imports = [
    "${toString modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    "${toString modulesPath}/installer/cd-dvd/channel.nix"
    "${toString modulesPath}/profiles/minimal.nix"
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Remove perl from activation
  boot.initrd.systemd.enable = true;
  system.etc.overlay.enable = true;
  services.userborn.enable = true;

  # Random perl remnants
  system.disableInstallerTools = true;
  programs.less.lessopen = null;
  boot.enableContainers = false;
  boot.loader.grub.enable = false;
  # does that matter??
  environment.defaultPackages = [];
  documentation.info.enable = false;

  services.getty.helpLine = lib.mkForce ''
    The "nixos" and "root" accounts have empty passwords.

    To log in over ssh you must set a password for either "nixos" or "root"
    with `passwd` (prefix with `sudo` for "root"), or add your public key to
    /home/nixos/.ssh/authorized_keys or /root/.ssh/authorized_keys.

    If you need a wireless connection, use `nmtui`.
		See the NixOS manual for details.
  '';

	networking.networkmanager.enable = true;

  networking.hostName = "nixos";

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  users.defaultUserShell = pkgs.bash;
  users.users.nixos = {
    useDefaultShell = true;
    packages = with pkgs; [
			mkpasswd
      tmux
      btop
      du-dust
			ripgrep
      eza
      fd
      jq
			nh
    ];
  };
	programs.git.enable = true;
  programs.neovim = {
		enable = true;
		defaultEditor = true;
	};

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    git
    nixos-rebuild
  ];

	isoImage.contents = [
	{
		source = ./..;
		recursive = true;
		target = "/home/nixos/upstream-config";
	}
	];

  environment.stub-ld.enable = false;

	# Use faster squashfs compression
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  system.stateVersion = "24.05";
}
