{
  jq,
  writeShellScriptBin,
  lib,
  ...
}:
writeShellScriptBin "imp-pkgs" ''
  nix profile list --json \
  | ${lib.getExe jq} \
  '.elements | to_entries | map(select(.value.attrPath != null)|select(.value.attrPath | startswith("legacyPackages.x86_64-linux") or startswith("pkgs"))) | .[] | .key' \
  -r
''
