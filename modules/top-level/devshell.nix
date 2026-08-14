{ inputs, ... }:
{
  flake-inputs.devshell = {
    url = "github:numtide/devshell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.devshell.flakeModule ];

  perSystem =
    {
      self',
      pkgs,
      lib,
      ...
    }:
    {
      devshells.default = {
        name = "puntbestanden";

        packages = builtins.attrValues {
          inherit (pkgs)
            just
            stow
            nh
            ;
          inherit (pkgs.nur.repos.dtomvan) sshp panix;
          pn = pkgs.writeShellApplication {
            name = "pn";
            text = ''
              bail () {
                echo "$0: FATAL: $*"
                exit 1
              }
              target="$1"; shift || bail No target provided
              action="$1"; shift || bail No action provided
              panix deploy "--activation-mode=$action" "--tags=$target" --log --exit-on-complete --require-all-success
            '';
          };
        };

        # make all flake apps available as commands. Very useful in the context
        # of numtide/devshell because you get to see the description without
        # doing `nix flake show`.
        commands = lib.mapAttrsToList (name: app: {
          inherit name;
          help = app.meta.description;
          command = ''
            pushd $(git rev-parse --show-toplevel)
            nix run .#${name}
            popd
          '';
        }) self'.apps;
      };
    };
}
