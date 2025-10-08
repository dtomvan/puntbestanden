{
  flake.modules.nixos.utilities =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.modules.utilities;
    in
    {
      # added for ISO. Makes no sense to do this on a fresh system or an offline
      # installer
      options.modules.utilities.enableLazyApps = lib.mkEnableOption "extras through lazy-app";

      config.environment.systemPackages =
        with pkgs;
        [
          wget
          curl
          nix-output-monitor
          nurl
          git
          jujutsu
          unzip
          zip
          libarchive
          gcc
          pkg-config
          gnumake
          usbutils
          pciutils
          e2fsprogs
          btrfs-progs
          util-linux
          dosfstools
        ]
        ++ lib.optionals cfg.enableLazyApps (
          lib.map (pkg: lazy-app.override { inherit pkg; }) [
            nix-tree
            nvd
            rar
            bzip2
            zstd
            lz4
            xz
            cmake
            meson
            tokei
            git-lfs
          ]
        );
    };
}
