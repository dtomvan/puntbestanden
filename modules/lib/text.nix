# Stolen from https://github.com/mightyiam/infra
{ lib, config, ... }:
{
  options.text = lib.mkOption {
    default = { };
    type = lib.types.lazyAttrsOf (
      lib.types.oneOf [
        (lib.types.separatedString "")
        (lib.types.submodule {
          options = {
            parts = lib.mkOption {
              type = lib.types.lazyAttrsOf lib.types.str;
            };
            order = lib.mkOption {
              type = lib.types.listOf lib.types.str;
            };
          };
        })
      ]
    );
    apply = lib.mapAttrs (
      _name: text:
      if lib.isAttrs text then
        text.order |> map (lib.flip lib.getAttr text.parts) |> lib.concatStrings
      else
        text
    );
  };

  config.perSystem =
    { pkgs, ... }:
    {
      packages = lib.mapAttrs' (
        n: v: lib.nameValuePair "text-file-${n}" (pkgs.writeText n v)
      ) config.text;
    };
}
