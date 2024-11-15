{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    gcc
    pkg-config
    gnumake
    cmake
    meson
  ];
}
