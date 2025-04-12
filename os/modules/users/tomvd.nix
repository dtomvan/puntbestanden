{
  config,
  pkgs,
  ...
}: {
  nix.settings = {
    trusted-users = ["tomvd"];
  };

  users.users.tomvd = {
    isNormalUser = true;
    createHome = true;
    # not sure which are needed but I don't want to debug these again
    extraGroups = ["wheel" "kvm" "audio" "seat" "libvirtd" "qemu-libvirtd" "lp" "scanner" "audio" "docker"];
    # Packages that I always want available, no matter if I have home-manager installed
    packages = with pkgs; [
      neovim
      btop
      du-dust
      eza
      fd
      jq
      ripgrep
      zathura
      gron
      nixfmt-rfc-style

      glow

      fastfetch

      wl-clipboard
      pavucontrol
      alsa-utils
      nix-tree
    ];
    hashedPasswordFile = config.sops.secrets."tomvd.pass".path;
  };

  sops.secrets."tomvd.pass" = {
    sopsFile = ../../../secrets/tomvd.pass.secret;
    neededForUsers = true;

    format = "binary";

    mode = "0600";
    owner = "tomvd";
    group = "users";
  };
}
