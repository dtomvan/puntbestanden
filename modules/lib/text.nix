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
        lib.pipe text.order [
          (map (lib.flip lib.getAttr text.parts))
          (map (lib.splitString "\n"))
          (map (map lib.trim))
          (map lib.concatLines)
          lib.concatStrings
        ]
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
