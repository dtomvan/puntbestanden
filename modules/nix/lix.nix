{
  flake.modules.nixos.nix-common =
    { pkgs, ... }:
    {
      nix.package = pkgs.lixPackageSets.stable.lix;
    };
}
