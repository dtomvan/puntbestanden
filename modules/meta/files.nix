{ inputs, ... }:
{
  flake-file.inputs = {
    files.url = "github:mightyiam/files";
  };

  imports = [
    inputs.files.flakeModules.default
  ];

  perSystem =
    { config, ... }:
    let
      description = "Write all files.files to the correct places";
    in
    {
      apps.write-files = {
        type = "app";
        program = config.files.writer.drv;
        meta = { inherit description; };
      };

      devshells.default.commands = [
        {
          name = "write-files";
          help = description; # yes.
          command = "nix run .#write-files";
        }
      ];
    };
}
