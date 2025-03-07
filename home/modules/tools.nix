{
  pkgs,
  lib,
  ...
}: let
  nix-tree = lib.getExe pkgs.nix-tree;
  jq = lib.getExe pkgs.jq;
in {
  home.packages = with pkgs; [
    (writers.writeBashBin "nix-run" ''
      nix run "$FLAKE#pkgs.$@"
    '')

    (writers.writeBashBin "nix-install" ''
      nix run "$FLAKE#pkgs.$@"
    '')

    (writers.writeBashBin "list-apps" ''
      ${jq} --dot ~/.nix-profile/bin/* \
      | grep -- '"home-manager-path" -> ".*"' \
      | awk '{print $3}' \
      | sort \
      | ${nix-tree} -sr ".[]"
    '')
    (writeShellScriptBin "imp-pkgs" ''
      nix profile list --json \
      | ${jq} \
      '.elements | to_entries | map(select(.value.attrPath != null)|select(.value.attrPath | startswith("legacyPackages.x86_64-linux") or startswith("pkgs"))) | .[] | .key' \
      -r
    '')
  ];
}
