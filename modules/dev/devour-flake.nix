{ inputs, ... }:
{
  flake-file.inputs = {
    devour-flake.url = "github:srid/devour-flake";
    devour-flake.flake = false;
  };

  perSystem =
    { self', pkgs, ... }:
    {
      packages = {
        devour-flake = pkgs.callPackage inputs.devour-flake { };
        nix-build-all = pkgs.writeShellApplication {
          name = "nix-build-all";
          runtimeInputs = [
            pkgs.nix
            pkgs.jq
            pkgs.coreutils
            self'.packages.devour-flake
          ];
          text = ''
            # Make sure that flake.lock is sync
            nix flake lock --no-update-lock-file

            # Do a full nix build (all outputs)
            # This uses https://github.com/srid/devour-flake
            while IFS=$'\t' read -r -a pkg
            do
              pname="''${pkg[0]}"
              outPath="''${pkg[1]}"
              ln -s "$outPath" "$pname"
            done < <(devour-flake . "$@" | jq -r 'to_entries | .[0].value.byName | to_entries | map([.key,.value]).[] | @tsv')
          '';
        };
      };

      devshells.default.packages = [ self'.packages.nix-build-all ];
    };
}
