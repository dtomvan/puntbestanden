{
  flake.modules.nixos.utilities =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      inherit (lib) mkEnableOption optionals;
      cfg = config.modules.utilities;
    in
    {
      # added for ISO. Makes no sense to do this on a fresh system or an offline
      # installer
      options.modules.utilities.enableLazyApps = mkEnableOption "extras through lazy-app";

      config.environment.systemPackages =
        builtins.attrValues {
          inherit (pkgs)
            # keep-sorted start
            aha
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
            smartmontools
            unzip
            usbutils
            util-linux
            wget
            zip
            # keep-sorted end
            ;
          inherit (pkgs.incus) client;
        }
        ++ optionals cfg.enableLazyApps (
          {
            inherit (pkgs)
              # keep-sorted start
              bzip2
              cmake
              git-lfs
              lz4
              meson
              nix-update
              nvd
              rar
              tokei
              xz
              zstd
              # keep-sorted end
              ;
          }
          |> builtins.attrValues
          |> lib.map (pkg: pkgs.lazy-app.override { inherit pkg; })
        );
    };
}
