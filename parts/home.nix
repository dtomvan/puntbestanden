{ self, inputs, ... }:
with inputs.nixpkgs.lib;
let
  mkPkgs = system: import ../lib/make-packages.nix { inherit self system inputs; };

  makeHome =
    _key: host:
    nameValuePair "tomvd@${host.hostName}" (
      inputs.home-manager.lib.homeManagerConfiguration {
        pkgs = mkPkgs host.system;

        modules = import ../home/modules.nix { inherit host inputs; };

        extraSpecialArgs = {
          inherit host inputs;
        };
      }
    );
in
{
  flake.homeConfigurations = mapAttrs' makeHome (import ../hosts.nix);
}
