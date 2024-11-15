{
  pkgs,
  config,
  lib,
  ...
}: {
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    trusted-users = ["tomvd"];
    experimental-features = ["nix-command" "flakes"];
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
    ../os-modules/hardware/nvidia.nix
    ../os-modules/hardware/ssd.nix

    ../os-modules/packagesets/archives.nix
    ../os-modules/packagesets/build-tools.nix
    ../os-modules/packagesets/nix-helpers.nix

    ../os-modules/networking/bluetooth.nix
    ../os-modules/networking/static-ip.nix
    ../os-modules/networking/iwd.nix

    ../os-modules/users/tomvd.nix

    ../os-modules/steam.nix
    ../os-modules/graphical-session.nix
    ../os-modules/printing.nix
  ];

  modules = {
    printing.useHPLip = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "tom-pc";

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  users.mutableUsers = false;

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
  ];

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
