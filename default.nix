{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> {inherit system;}, # on one of my nixos configs, this is just always flake nixpkgs, otherwise good luck
  ...
}:
  (pkgs.lib.filesystem.packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = ./packages/by-name;
  })
