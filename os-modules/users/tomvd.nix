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
    hashedPassword = "$6$H7z49YyQ3UJkW5rC$C.EWZnpCX9c1/OJPB.sbq9iqFbEwrHYsm2Whn5GbJJPsu05VFWo3V71sxUydb9rhLjDUB.pqVwiESolfOORID0";
  };
  programs.zsh.enable = true;
  programs.neovim.defaultEditor = true;
}
