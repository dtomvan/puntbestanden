# sets the system for NixOS. takes a system, returns a NixOS module
{ withSystem, ... }:
{
  flake.lib.system =
    system:
    (withSystem system (
      {
        self',
        inputs',
        pkgs,
        ...
      }:
      {
        _module.args = { inherit self' inputs'; };
        nixpkgs = { inherit pkgs; };
      }
    ));
}
