{
  perSystem =
    { pkgs, ... }:
    {
      packages.nixpkgs-update-telegram = pkgs.writeShellApplication {
        name = "nixpkgs-update-telegram";
        runtimeInputs = with pkgs; [
          nix-update
          git
        ];
        text = ''
          declare -a pkgs
          declare -a EXTRA_ARGS

          DO_BUILD="''${DO_BUILD:-1}"
          EXTRA_ARGS=( "$@" )
          if [ "$DO_BUILD" -eq 1 ]; then
            EXTRA_ARGS+=(--build)
          fi

          pkgs=(
            telegram-desktop
            _64gram
            ayugram-desktop
            kotatogram-desktop
            materialgram
          )
          if [ "$(hostname)" == boomer ]; then
            export NIX_CONFIG="builders = "
          fi

          for pkg in "''${pkgs[@]}"; do
            nix-update --format --commit -u "$pkg.unwrapped" "''${EXTRA_ARGS[@]}" || true
          done
        '';
      };
    };

  flake.modules.nixos.hosts-boomer =
    { pkgs, ... }:
    {
      environment.systemPackages = [ pkgs.nixpkgs-update-telegram ];
    };
}
