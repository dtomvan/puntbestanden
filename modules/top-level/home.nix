{
  config,
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
          modules = [ config.flake.modules.homeManager."hosts-${host.hostName}" ];
        }
      )
    );
in
{
  imports = [ inputs.home-manager.flakeModules.default ];

  flake.homeConfigurations = pipe config.flake.hosts [
    (filterAttrs (_k: v: !(v ? noConfig)))
    (mapAttrs' makeHome)
  ];
}
