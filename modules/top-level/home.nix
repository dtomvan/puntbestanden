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
    attrValues
    concatMap
    filterAttrs
    listToAttrs
    nameValuePair
    pipe
    ;

  makeHome =
    host:
    (map (
      user:
      nameValuePair "${user}@${host.hostName}" (
        withSystem host.system (
          {
            self',
            inputs',
            pkgs,
            ...
          }:
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ self.modules.homeManager."${user}-${host.hostName}" ];
            extraSpecialArgs = { inherit self' inputs'; };
          }
        )
      )
    ) (attrNames config.users));
in
{
  imports = [ inputs.home-manager.flakeModules.default ];

  flake-file.inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.homeConfigurations = pipe self.hosts [
    (filterAttrs (_k: v: !(v ? noConfig)))
    attrValues
    (concatMap makeHome)
    listToAttrs
  ];

  text.readme.parts.home_configs = "\n- a dendritic home-manager config (TODO: list aspects here)";
}
