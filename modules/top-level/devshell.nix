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
    { pkgs, ... }:
    {
      devshells.default = {
        name = "puntbestanden";

        packages = with pkgs; [
          just
          stow
        ];
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
  '';
}
