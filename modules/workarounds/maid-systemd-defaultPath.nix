{ lib, ... }: {
  flake.modules.maid.maid-common.options.systemd.defaultPath = lib.mkOption {
    type = with lib.types; listOf package;
    default = [ ];
    description = ''
      Packages appended to the {env}`PATH` environment variable of all
      system and user services.

      Individual services can opt out by setting `enableDefaultPath = false`.
    '';
  };
}
