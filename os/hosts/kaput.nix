{
  pkgs,
  ...
}:
{
  imports = [
    ../modules/utilities.nix
    ../modules/networking/tailscale.nix
    ../modules/services/syncthing.nix

    ../modules/services/portainer.nix
    ../modules/services/pihole.nix
  ];

  _module.args.nixinate = {
    host = "kaput";
    sshUser = "root";
    buildOn = "local";
    substituteOnTarget = true;
    hermetic = true;
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.een = {
    isNormalUser = true;
    description = "123";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  environment.systemPackages = with pkgs; [
    tmux
  ];

  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  programs.less.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "25.05";
}
