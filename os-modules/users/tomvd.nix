{pkgs, ...}: {
  users.users.tomvd = {
    isNormalUser = true;
    createHome = true;
    shell = pkgs.zsh;
    # not sure which are needed but I don't want to debug these again
    extraGroups = ["wheel" "kvm" "audio" "seat" "libvirtd" "qemu-libvirtd" "lp" "audio"];
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
      wl-clipboard
      pavucontrol
      alsa-utils
      nix-tree
      mpv
    ];
    hashedPassword = "$y$j9T$Ze3xItl54/1SRkq0Iry6E.$wsj4ufLq2EsHTFb526MgMT.1UBADpPTX/Snq2evTCf6";
  };
  programs.zsh.enable = true;
  programs.neovim.defaultEditor = true;
}
