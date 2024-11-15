{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    nh
    nix-fast-build
    nix-output-monitor
    nvd
  ];
}
