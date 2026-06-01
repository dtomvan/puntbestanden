# denful/flake-file lite. Just for inputs. Doesn't work with anything except
# for a flake-parts flake that imports all of ./modules from the root. Which is
# my usecase.
let
  flake-inputs =
    { config, lib, ... }:
    let
      cfg = config.flake-inputs;
      inherit (lib) mkOption;
      inherit (lib.types) attrs;
    in
    {
      options.flake-inputs = mkOption {
        type = attrs;
        default = { };
      };

      config.perSystem =
        { pkgs, ... }:
        let
          inherit (pkgs)
            writeShellApplication
            gitMinimal
            nix-converter
            nixfmt
            ;
        in
        {
          packages.write-flake = writeShellApplication {
            name = "write-flake";
            runtimeInputs = [
              gitMinimal
              nixfmt
              nix-converter
            ];
            excludeShellChecks = [
              "SC2089"
              "SC2090"
            ];
            derivationArgs = {
              preferLocalBuild = true;
              allowSubstitutes = false;
            };
            runtimeEnv.flakeInputs = builtins.toJSON cfg;
            text = ''
              pushd "$(git rev-parse --show-toplevel)"
              cat <<EOF > flake.nix
              {
                outputs =
                  inputs:
                  inputs.flake-parts.lib.mkFlake { inherit inputs; } (
                    { lib, ... }:
                    let
                      import-tree = ${builtins.readFile ../lib/_import-tree.nix};
                    in
                    {
                      imports = import-tree lib (toString ./. + "/modules");
                    }
                  );

                inputs =
              EOF

              nix-converter <<< "''${flakeInputs:?}" >> flake.nix

              cat << EOF >> flake.nix
                ;
              }
              EOF
              nixfmt flake.nix
            '';
          };
        };
    };
in
{
  imports = [ flake-inputs ];
  flake.flakeModules = { inherit flake-inputs; };
}
