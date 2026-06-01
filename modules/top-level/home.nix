{
  self,
  config,
  inputs,
  withSystem,
  ...
}:
let
  inherit (inputs.nixpkgs.lib)
    attrNames
    concatMap
    listToAttrs
    nameValuePair
    ;

  hosts = config.hosts |> builtins.attrValues |> builtins.filter (host: host.hasConfig);

  makeHome =
    {
      name ? "${user}@${hostName}",
      user,
      hostName ? "",
      system,
    }:
    nameValuePair name (
      withSystem system (
        {
          self',
          inputs',
          pkgs,
          ...
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            (self.lib.mkHomeDefaults user)
            (self.modules.homeManager."${user}@${hostName}" or { })
            (self.modules.homeManager."users-${user}" or { })
          ];
          extraSpecialArgs = { inherit self' inputs'; };
        }
      )
    );

  makeHomes =
    user:
    # for host-specific configs
    (map (
      host:
      makeHome {
        inherit user;
        inherit (host) system;
        inherit (host.networking) hostName;
      }
    ) hosts)
    ++ [
      # for home-manager users not tied to a NixOS host.
      (makeHome {
        inherit user;
        name = user;
        system = "x86_64-linux";
      })
    ];
in
{
  imports = [ inputs.home-manager.flakeModules.default ];

  flake-inputs.home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.homeConfigurations = config.users |> attrNames |> concatMap makeHomes |> listToAttrs;

  text.readme.parts.home_configs = "\n- a dendritic home-manager config (TODO: list aspects here)";
}
