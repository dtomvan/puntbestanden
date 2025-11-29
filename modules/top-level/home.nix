{
  self,
  inputs,
  withSystem,
  ...
}:
let
  inherit (inputs.nixpkgs.lib)
    filterAttrs
    mapAttrs'
    nameValuePair
    pipe
    ;

  makeHome =
    _key: host:
    nameValuePair "tomvd@${host.hostName}" (
      withSystem host.system (
        { pkgs, ... }:
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ self.modules.homeManager."hosts-${host.hostName}" ];
        }
      )
    );
in
{
  imports = [ inputs.home-manager.flakeModules.default ];

  flake-file.inputs = {
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.homeConfigurations = pipe self.hosts [
    (filterAttrs (_k: v: !(v ? noConfig)))
    (mapAttrs' makeHome)
  ];

  text.readme.parts.home_configs = "\n- a dendritic home-manager config (TODO: list aspects here)";

  perSystem =
    { pkgs, lib, ... }:
    {
      devshells.default.commands = [
        {
          name = "update-home";
          help = "Switch to new home-manager configuration";
          command = "${lib.getExe pkgs.nh} home switch";
        }
      ];
    };
}
