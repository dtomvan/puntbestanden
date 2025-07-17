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
    {
      apps.write-files = {
        type = "app";
        program = config.files.writer.drv;
        meta.description = "Write all files.files to the correct places";
      };
    };
}
