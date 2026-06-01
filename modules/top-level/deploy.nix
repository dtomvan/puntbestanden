{
  withSystem,
  self,
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (builtins) filter listToAttrs;
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
  };

  imports = [ inputs.deploy-rs.flakeModules.default ];

  deploy.nodes =
    config.hosts
    |> filterAttrs (_n: v: v.hasConfig)
    |> mapAttrs' (
      _n: v:
      nameValuePair v.networking.hostName (
        withSystem v.system (
          systemArgs@{ inputs', pkgs, ... }:
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

            homeProfiles =
              v.users
              |> map (
                user:
                nameValuePair "home-${user}" {
                  inherit user;
                  path = deployLib.activate.home-manager {
                    base = self.homeConfigurations."${user}@${v.networking.hostName}";
                  };
                }
              )
              |> listToAttrs;

            nixvimProfiles =
              v.users
              |> filter (user: config.users.${user}.nixvim.enable)
              |> map (
                user:
                nameValuePair "nixvim-${user}" {
                  inherit user;
                  path = deployLib.activate.profile {
                    base = config.users.${user}.nixvim.package (systemArgs // { host = v; });
                    profileName = "nixvim";
                    priority = 4; # ahead of default priority, so home-manager can also install neovim without both colliding
                  };
                }
              )
              |> listToAttrs;
          in
          {
            hostname = v.networking.hostName;

            profiles =
              optionalAttrs v.flatpak.enable flatpakProfiles
              // optionalAttrs v.enableHomeManager homeProfiles
              // optionalAttrs v.enableNixvim nixvimProfiles;
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
