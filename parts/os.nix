{ self, inputs, ... }:
with inputs.nixpkgs.lib;
let
  nixConfig = import ../nix-config.nix;

  getHosts = type: filterAttrs (_k: v: hasInfix type v.system) (import ../hosts.nix);
  mkPkgs = system: import ../lib/make-packages.nix { inherit self system inputs; };

  makeNixos =
    _key: host:
    nameValuePair host.hostName (nixosSystem {
      specialArgs = {
        inherit host nixConfig inputs;
      };
      modules = import ../os/modules.nix { inherit host inputs; } ++ host.os.extraModules; # nixpkgs is dumb
      pkgs = mkPkgs host.system;
    });
in
{
  flake.nixosConfigurations = (mapAttrs' makeNixos (getHosts "linux"));
}
