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
          btrfs-progs
          curl
          dix
          dosfstools
          e2fsprogs
          gcc
          git
          gnumake
          jujutsu
          libarchive
          nix-diff
          nix-output-monitor
          nix-tree
          nurl
          pciutils
          pkg-config
          unzip
          usbutils
          util-linux
          wget
          zip
        ]
        ++ lib.optionals cfg.enableLazyApps (
          lib.map (pkg: lazy-app.override { inherit pkg; }) [
            bzip2
            cmake
            git-lfs
            lz4
            meson
            nvd
            rar
            tokei
            xz
            zstd
            nix-update
          ]
        );
    };
}
