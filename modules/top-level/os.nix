{
  inputs,
  config,
  withSystem,
  ...
}:
let
  inherit (inputs.nixpkgs.lib)
    filterAttrs
    hasInfix
    mapAttrs'
    nameValuePair
    nixosSystem
    pipe
    ;

  inherit (config.flake) hosts;

  makeNixos =
    _key: host:
    nameValuePair host.hostName (nixosSystem {
      modules = [
        (withSystem host.system (
          { pkgs, ... }:
          {
            nixpkgs = { inherit pkgs; };
            networking = { inherit (host) hostName; };
          }
        ))
        config.flake.modules.nixos."hosts-${host.hostName}"
        ../../hardware/${host.hostName}.nix
      ];
    });
in
{
  flake.nixosConfigurations = pipe hosts [
    (filterAttrs (_k: v: hasInfix "linux" v.system && !(v ? noConfig)))
    (mapAttrs' makeNixos)
  ];
}
