{
  flake-parts-lib,
  lib,
  self,
  ...
}:
let
  inherit (lib)
    mkOption
    escapeShellArg
    concatMapAttrsStringSep
    mapAttrs'
    ;
  inherit (lib.types)
    attrsOf
    package
    either
    pathInStore
    ;
in
{
  options.perSystem = flake-parts-lib.mkPerSystemOption (
    { pkgs, config, ... }:
    let
      inherit (config) files;
    in
    {
      options.files = mkOption {
        default = { };
        type = attrsOf (either package pathInStore);
      };

      config = {
        apps.write-files = {
          type = "app";
          program = pkgs.writeShellApplication {
            name = "write-files";
            runtimeInputs = [ pkgs.gitMinimal ];
            preferLocalBuild = true;
            text = ''
              pushd "$(git rev-parse --show-toplevel)"
            ''
            + (concatMapAttrsStringSep "\n" (p: drv: ''
              mkdir -p "$(dirname ${escapeShellArg p})"
              cp ${drv} ${escapeShellArg p}
            '') files);
          };

          meta.description = "Write all files.files to the correct places";
        };

        checks = mapAttrs' (p: drv: {
          name = "files/${p}";
          value = pkgs.runCommand "files-check-${p}" { nativeBuildInputs = [ pkgs.difftastic ]; } ''
            difft --exit-code --display inline "${drv}" ${escapeShellArg "${self}/${p}"}
            touch $out
          '';
        }) files;
      };
    }
  );

}
