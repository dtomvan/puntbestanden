{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # I sometimes prefer one over the other: one is faster, the other more versatile.
    cloc
    tokei
    git-lfs
    jujutsu
  ];
}
