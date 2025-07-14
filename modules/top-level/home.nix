{ config, inputs, ... }:
let
  inherit (inputs.nixpkgs.lib)
    nameValuePair
    mapAttrs'
    ;

  makeHome =
    _key: host:
    nameValuePair "tomvd@${host.hostName}" (
      inputs.home-manager.lib.homeManagerConfiguration {
        modules = import ../../home/modules.nix { inherit host inputs; };

        extraSpecialArgs = {
          inherit host inputs;
        };
      }
    );
in
{
  flake.homeConfigurations = mapAttrs' makeHome config.flake.hosts;
}
