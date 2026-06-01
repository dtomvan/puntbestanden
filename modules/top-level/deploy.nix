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
          systemArgs@{ inputs', self', ... }:
          let
            deployLib = inputs'.deploy-rs.legacyPackages.lib;
            hostConfig = self.nixosConfigurations.${v.networking.hostName};

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

            profiles = {
              system = {
                user = "root";
                sshUser = "root";
                path = deployLib.activate.nixos {
                  base = hostConfig;
                };
              };

            }
            // optionalAttrs v.enableFlatpak {
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
