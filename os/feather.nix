{pkgs, ...}: {
  imports = [
    ./modules/utilities.nix
    ./modules/programs/gpg.nix

    ./modules/networking/tailscale.nix

    ./modules/services/keybase.nix
    ./modules/services/syncthing.nix

    ./modules/virt/distrobox.nix
  ];

  _module.args.nixinate = {
    host = "feather";
    sshUser = "root";
    buildOn = "local";
    substituteOnTarget = true;
    hermetic = false;
  };

  services.olive-c.enable = true;
  services.koil.enable = true;

  modules = {
    printing.useHPLip = true;

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

  environment.systemPackages = with pkgs; [
    home-manager
    wget
    curl
    nh
    wl-clipboard
    git
    libreoffice-qt6-fresh

    keepassxc
  ];

  hardware.bluetooth.enable = true;

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
