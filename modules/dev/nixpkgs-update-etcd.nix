{
  perSystem =
    { pkgs, ... }:
    {
      packages.nixpkgs-update-etcd = pkgs.callPackage (
        {
          writeShellApplication,
          git,
          nix-update,
        }:
        writeShellApplication {
          name = "nixpkgs-update-etcd";
          runtimeInputs = [
            git
            nix-update
          ];
          runtimeEnv.etcds = [
            "3.6"
            "3.7"
          ];
          text = ''
            declare -a EXTRA_ARGS

            DO_BUILD="''${DO_BUILD:-1}"
            EXTRA_ARGS=( "$@" )
            if [ "$DO_BUILD" -eq 1 ]; then
              EXTRA_ARGS+=(--build --test)
            fi

            if [ "$(hostname)" == boomer ]; then
              export NIX_CONFIG="builders = "
            fi

            for etcd in "''${etcds[@]}"; do
              etcd_underscored="''${etcd/./_}"
              nix-update --format --commit --version-regex "v($etcd\.\d+)" -u "etcd_$etcd_underscored" "''${EXTRA_ARGS[@]}" || true
            done
          '';
        }
      ) { };
    };

  flake.modules.nixos.hosts-boomer =
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.nixpkgs-update-etcd ];
    };
}
