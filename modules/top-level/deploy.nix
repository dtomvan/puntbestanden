{
  withSystem,
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    filterAttrs
    optionalAttrs
    mapAttrs'
    nameValuePair
    ;
in
{
  flake-inputs.deploy-rs = {
    url = "git+https://git.toostveen.nl/tom/deploy-rs";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.flake-parts.follows = "flake-parts";
    inputs.treefmt-nix.follows = "treefmt-nix";
  };

  imports = [ inputs.deploy-rs.flakeModules.default ];

  deploy.nodes =
    config.hosts
    |> filterAttrs (_n: v: v.hasConfig)
    |> mapAttrs' (
      _n: v:
      nameValuePair v.networking.hostName (
        withSystem v.system (
          { inputs', pkgs, ... }:
          let
            deployLib = inputs'.deploy-rs.legacyPackages.lib;

            flatpakProfiles.flatpak = {
              user = "root";
              sshUser = "root";
              path = deployLib.activate.custom {
                base = pkgs.runCommand "empty" { } ''
                  mkdir -p $out
                '';
                activate =
                  #bash
                  let
                    inherit (v.flatpak) packages;
                    inherit (lib) optionalString escapeShellArgs;
                  in
                  ''
                    flatpak="/run/current-system/sw/bin/flatpak"
                    "$flatpak" remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
                    ${optionalString (packages != [ ]) ''
                      "$flatpak" install --noninteractive --or-update ${escapeShellArgs packages}
                    ''}
                    "$flatpak" update --noninteractive
                  '';
              };
            };
          in
          {
            hostname = v.networking.hostName;

            profiles = optionalAttrs v.flatpak.enable flatpakProfiles;
          }
        )
      )
    );

  perSystem =
    { inputs', ... }:
    {
      devshells.default.packages = [ inputs'.deploy-rs.packages.default ];
    };
}
