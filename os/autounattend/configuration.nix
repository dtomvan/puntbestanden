# configuration for the TARGET system.
{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.sops.nixosModules.default
    ./disko.nix
    ./hardware-configuration.nix

    ../common.nix
    ../modules/boot/systemd-boot.nix
    ../modules/networking/tailscale.nix
    ../modules/networking/wifi-passwords.nix
    ../modules/services/ssh.nix
    ../modules/users/tomvd.nix
    ../modules/utilities.nix
  ];

  # broadcom-sta fails to build: https://github.com/NixOS/nixpkgs/pull/421163
  # also remove in installer.nix after fix
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_12_hardened;

  # not needed at all OOTB
  networking.networkmanager.plugins = lib.mkForce [ ];

  environment.systemPackages = with pkgs; [
    gh
    git
  ];

  services.getty = {
    autologinUser = "tomvd";
    helpLine = lib.strings.trim ''
      root password is "nixos"
      tomvd password is "tomvd"
      use nmtui to connect to Wi-Fi
    '';
  };

  environment.sessionVariables.NH_FLAKE = "/etc/nixos";

  home-manager.users.tomvd = {
    home.homeDirectory = "/home/tomvd";
    programs.bash = {
      enable = true;
      initExtra = # bash
        ''
          fastfetch
          systemd-analyze

          echo > README <<EOF
          You made it!
          Further steps:

          Either clone your own dotfiles:
            $ git clone https://github.com/me/my-dotfiles
            $ cd my-dotfiles
            $ nixos-generate-config --show-hardware-config > hardware-configuration.nix
            $ nh os boot -H myhostname .
            $ reboot

          Or setup a new config from scratch:
            $ sudo nixos-generate-config --force

          Or with flakes:
            $ sudo nixos-generate-config --flake --force

          Or SSH into this device:
            $ sudo hostname non-generic-name
            $ sudo tailscale up

          Or, if you are dtomvan, grab one of your configs:
            # NH_FLAKE is already set
            $ nh os boot -H {boomer,feather,kaput}

          EOF

          echo 'cat README for help'
        '';
    };
    home.stateVersion = "25.05";
  };

  users.users.tomvd.hashedPassword = lib.mkForce null;
  users.users.tomvd.initialPassword = "tomvd";
  users.users.root.initialPassword = "nixos";

  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  programs.less.enable = true;
  networking.firewall.enable = true;

  system.stateVersion = "25.05";
}
