{
  withSystem,
  self,
  inputs,
  lib,
  config,
  ...
}:
let
  inherit (builtins) listToAttrs;
  inherit (lib)
    filterAttrs
    mapAttrs'
    nameValuePair
    ;
in
{
  flake-file.inputs.deploy-rs = {
    url = "github:dtomvan/deploy-rs/refactor";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  imports = [ inputs.deploy-rs.flakeModules.default ];

  deploy.nodes =
    config.hosts
    |> filterAttrs (_n: v: v.hasConfig)
    |> mapAttrs' (
      _n: v:
      nameValuePair v.hostName (
        withSystem v.system (
          { inputs', self', ... }:
          let
            deployLib = inputs'.deploy-rs.legacyPackages.lib;
            hostConfig = self.nixosConfigurations.${v.hostName};
            homeProfiles = listToAttrs (
              map (
                user:
                nameValuePair "home-${user}" {
                  inherit user;
                  path = deployLib.activate.home-manager {
                    base = self.homeConfigurations."${user}@${v.hostName}";
                  };
                }
              ) v.users
            );
          in
          {
            # yes.
            hostname = v.hostName;

            profiles = {
              system = {
                user = "root";
                sshUser = "root";
                path = deployLib.activate.nixos {
                  base = hostConfig;
                };
              };

              # TODO: unhardcode tomvd username, also allow to be configured per-host through flake-parts.
              # we could set deploy.nodes.<hostname>.profiles.nixvim seperately through the module system
              nixvim = {
                user = "tomvd";
                path = deployLib.activate.profile {
                  base = self'.packages.nixvim.overrideAttrs { dontFixup = true; };
                  profileName = "nixvim";
                  priority = 4; # ahead of default priority, so home-manager can also install neovim without both colliding
                };
              };

              flatpak = {
                user = "root";
                sshUser = "root";
                path = deployLib.activate.custom {
                  base = self'.legacyPackages.activatable-flatpak {
                    inherit (hostConfig.config.services.flatpak) packages;
                  };
                  activate = "./bin/flatpak-managed-install";
                };
              };
            }
            // homeProfiles;
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
