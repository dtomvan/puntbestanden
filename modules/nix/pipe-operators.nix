{
  flake.modules.nixos.nix-common =
    { config, lib, ... }:
    {
      nix.settings.experimental-features = lib.singleton (
        if config.nix.package.pname == "lix" then "pipe-operator" else "pipe-operators"
      );
    };
}
