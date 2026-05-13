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
    mapAttrs'
    nameValuePair
    ;
in
{
  flake-file.inputs.deploy-rs = {
    url = "github:dtomvan/deploy-rs";
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
          systemArgs@{ inputs', self', ... }:
          let
            deployLib = inputs'.deploy-rs.legacyPackages.lib;
            hostConfig = self.nixosConfigurations.${v.hostName};

            homeProfiles =
              v.users
              |> map (
                user:
                nameValuePair "home-${user}" {
                  inherit user;
                  path = deployLib.activate.home-manager {
                    base = self.homeConfigurations."${user}@${v.hostName}";
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
            // homeProfiles
            // nixvimProfiles;
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
