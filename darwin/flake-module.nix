{ inputs, ... }:
with inputs.nixpkgs.lib;
let
  getHosts = type: filterAttrs (_k: v: hasInfix type v.system) (import ../hosts.nix);

  makeDarwin =
    _key: host:
    nameValuePair host.hostName (
      nix-darwin.lib.darwinSystem {
        specialArgs = {
          inherit host nixConfig inputs;
        };
        modules = [ ./hosts/${host.hostName}.nix ];
      }
    );
in
{
  flake.darwinConfigurations = mapAttrs' makeDarwin (getHosts "darwin");
}
