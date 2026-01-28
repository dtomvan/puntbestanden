{
  perSystem =
    { pkgs, ... }:
    {
      packages.nixpkgs-update-telegram = pkgs.writeShellApplication {
        name = "nixpkgs-update-telegram";
        runtimeInputs = with pkgs; [
          git
          nix-update
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
            ada # dependency of all the telegrams, only really used for td
            tdlib
            telegram-desktop.unwrapped
            _64gram.unwrapped
            ayugram-desktop.unwrapped
            kotatogram-desktop.unwrapped
            materialgram.unwrapped
          )
          if [ "$(hostname)" == boomer ]; then
            export NIX_CONFIG="builders = "
          fi

          for pkg in "''${pkgs[@]}"; do
            nix-update --format --commit -u "$pkg" "''${EXTRA_ARGS[@]}" || true
          done
        '';
      };
    };

  flake.modules.nixos.hosts-boomer =
    { self', ... }:
    {
      environment.systemPackages = [ self'.packages.nixpkgs-update-telegram ];
    };
}
