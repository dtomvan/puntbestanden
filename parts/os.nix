{ inputs, ... }:
let
  inherit (inputs.nixpkgs.lib)
    filterAttrs
    hasInfix
    mapAttrs'
    nameValuePair
    nixosSystem
    pipe
    ;

  nixConfig = import ../nix-config.nix;

  makeNixos =
    _key: host:
    nameValuePair host.hostName (nixosSystem {
      specialArgs = {
        inherit host nixConfig inputs;
      };
      modules = import ../os/modules.nix { inherit host inputs; } ++ host.os.extraModules; # nixpkgs is dumb
    });
in
{
  flake.nixosConfigurations = pipe (import ../hosts.nix) [
    (filterAttrs (_k: v: hasInfix "linux" v.system))
    (mapAttrs' makeNixos)
  ];
}
