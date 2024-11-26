{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nh
    nix-fast-build
    nix-output-monitor
    nvd
    nix-init
    nurl
    nix-tree
  ];
}
