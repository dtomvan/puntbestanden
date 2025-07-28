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

        packages = with pkgs; [
          just
          stow
        ];

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

      files.files = [
        {
          path_ = ".envrc.recommended";
          drv = pkgs.writeText ".envrc.recommended" ''
            if ! has nix_direnv_version || ! nix_direnv_version 3.1.0; then
              source_url "https://raw.githubusercontent.com/nix-community/nix-direnv/3.1.0/direnvrc" "sha256-yMJ2OVMzrFaDPn7q8nCBZFRYpL/f0RcHzhmw/i6btJM="
            fi

            use flake
          '';
        }
      ];
    };

  text.gitignore = ''
    /.direnv
    /.tmp
  '';
}
