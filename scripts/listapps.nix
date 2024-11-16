{pkgs, ...}: {
  home.packages = [
    (pkgs.writers.writeBashBin "list-apps" ''
      ${pkgs.nix-tree}/bin/nix-tree --dot ~/.nix-profile/bin/* \
      | grep -- '"home-manager-path" -> ".*"' \
      | awk '{print $3}' \
      | sort \
      | ${pkgs.jq}/bin/jq -sr ".[]"
    '')
  ];
}
