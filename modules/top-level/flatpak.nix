{
  lib,
  config,
  ...
}:
let
  inherit (lib)
    filterAttrs
    mapAttrs'
    nameValuePair
    ;
in
{
  perSystem =
    { pkgs, ... }:
    {
      packages =
        filterAttrs (_n: v: v.flatpak.enable) config.hosts
        |> mapAttrs' (
          _n: v:
          let
            inherit (v.flatpak) packages;
            inherit (lib) optionalString escapeShellArgs;
          in
          pkgs.writeShellApplication {
            name = "flatpak-managed-activate";
            text = ''
              flatpak="/run/current-system/sw/bin/flatpak"
              "$flatpak" remote-add --if-not-exists --system flathub https://dl.flathub.org/repo/flathub.flatpakrepo
              ${optionalString (packages != [ ]) ''
                "$flatpak" install --noninteractive --or-update --system flathub ${escapeShellArgs packages}
              ''}
              "$flatpak" update --noninteractive --system
            '';
          }
          |> nameValuePair "flatpak-${v.networking.hostName}"
        );
    };
}
