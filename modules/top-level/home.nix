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

          modules = import ../../home/modules.nix { inherit host inputs; };

          extraSpecialArgs = {
            inherit host inputs;
          };
        }
      )
    );
in
{
  flake.homeConfigurations = pipe config.flake.hosts [
    (filterAttrs (_k: v: !(v ? noConfig)))
    (mapAttrs' makeHome)
  ];
}
