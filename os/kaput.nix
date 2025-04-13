{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./modules/utilities.nix
    ./modules/networking/tailscale.nix
  ];

  _module.args.nixinate = {
    host = "kaput";
    sshUser = "tomvd";
    buildOn = "local";
    substituteOnTarget = true;
    hermetic = true;
  };

  modules.utilities = {
    archives = true;
    build-tools = true;
    linux = true;
    nix = true;
    repos = true;
  };

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.een = {
    isNormalUser = true;
    description = "123";
    extraGroups = ["networkmanager" "wheel"];
  };

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    nh
  ];

  programs.nix-ld.enable = true;
  services.envfs.enable = true;

  programs.less.enable = true;
  programs.command-not-found.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  networking.firewall.enable = false;

  system.stateVersion = "25.05";
}
