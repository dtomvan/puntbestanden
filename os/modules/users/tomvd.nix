{
  pkgs,
  host,
  ...
}:
{
  nix.settings = {
    trusted-users = [ "tomvd" ];
  };

  users.users.tomvd = {
    isNormalUser = true;
    createHome = true;
    # not sure which are needed but I don't want to debug these again
    extraGroups = [
      "wheel"
      "kvm"
      "audio"
      "seat"
      "libvirtd"
      "qemu-libvirtd"
      "lp"
      "scanner"
      "audio"
      "docker"
    ];
    # Packages that I always want available, no matter if I have home-manager installed
    packages =
      with pkgs;
      [
        bat
        btop
        du-dust
        eza
        fastfetch
        fd
        file
        glow
        gron
        jq
        just
        neovim
        nixfmt-rfc-style
        nix-tree
        rink
        ripgrep
        skim
        tealdeer
      ]
      ++ lib.optionals host.os.isGraphical [
        wl-clipboard
        pavucontrol
        alsa-utils
      ];

    hashedPassword = "$y$j9T$UNKC2ue19sYmCgHQGWcVE.$.6FqJwASbIV0O7c1hJM7BsPnGV6j98lMzr635nHmwA4";
  };
}
