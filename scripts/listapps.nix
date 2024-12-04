{pkgs, lib, ...}: {
  home.packages = [
    (pkgs.writers.writeBashBin "list-apps" ''
      ${lib.getExe pkgs.nix-tree} --dot ~/.nix-profile/bin/* \
      | grep -- '"home-manager-path" -> ".*"' \
      | awk '{print $3}' \
      | sort \
      | ${lib.getExe pkgs.jq} -sr ".[]"
    '')
  ];
}
