{
  pkgs,
  config,
  lib,
  ...
}: let
  imp-pkgs = pkgs.writers.writeBashBin "imp-pkgs" ''
    nix profile list --json \
    | ${lib.getExe pkgs.jq} \
    '.elements | to_entries | map(select(.value.attrPath != null)|select(.value.attrPath | startswith("legacyPackages.x86_64-linux") or startswith("pkgs"))) | .[] | .key' \
    -r
  '';
in {
  environment.systemPackages = with pkgs; [
    imp-pkgs
  ];
}
