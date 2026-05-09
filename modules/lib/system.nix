# sets the system for NixOS. takes a system, returns a NixOS module
{ withSystem, lib, ... }:
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
        nixpkgs.pkgs = lib.mkForce pkgs;
      }
    ));
}
