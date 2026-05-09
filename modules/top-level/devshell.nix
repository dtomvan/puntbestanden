{ inputs, ... }:
{
  flake-file.inputs = {
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
