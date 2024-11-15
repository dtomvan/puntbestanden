{
  pkgs,
  lib,
  config,
  ...
}: let
  git-clone =
    lib.writers.writeShellApplication {
    };
in {
  home.packages = [git-clone];
}
