{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.utilities;
in {
  options.modules.utilities = {
    nix = lib.mkEnableOption "nix utils";
    archives = lib.mkEnableOption "tar/unzip etc.";
    build-tools = lib.mkEnableOption "meson/cmake etc.";
    linux = lib.mkEnableOption "usb/fs utils";
    repos = lib.mkEnableOption "repo utils (jj)";
  };

  config.environment.systemPackages = with pkgs;
    lib.optionals cfg.nix [
      nh
      nix-fast-build
      nix-output-monitor
      nvd
      nix-init
      nurl
      nix-tree
    ]
    ++ lib.optionals cfg.archives [
      unzip
      zip
      libarchive
      rar
      bzip2
      zstd
      lz4
      xz
    ]
    ++ lib.optionals cfg.build-tools [
      gcc
      pkg-config
      gnumake
      cmake
      meson
    ]
    ++ lib.optionals cfg.linux [
      usbutils
      pciutils
      e2fsprogs
      btrfs-progs
      util-linux
      dosfstools
    ]
    ++ lib.optionals cfg.repos [
      git
      tokei
      git-lfs
      jujutsu
    ];
}
