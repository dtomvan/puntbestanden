# sets the system for NixOS. takes a system, returns a NixOS module
{ withSystem, ... }:
{
  flake.lib.system =
    system:
    (withSystem system (
      { pkgs, ... }:
      {
        nixpkgs = { inherit pkgs; };
      }
    ));
}
