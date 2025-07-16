{
  inputs,
  config,
  withSystem,
  ...
}:
let
  inherit (inputs.nixpkgs.lib)
    attrsToList
    filterAttrs
    hasInfix
    length
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
        ../hardware/_generated/${host.hostName}.nix
      ];
    });
in
{
  flake.nixosConfigurations = pipe hosts [
    (filterAttrs (_k: v: hasInfix "linux" v.system && !(v ? noConfig)))
    (mapAttrs' makeNixos)
  ];

  text.readme.parts.nixos_configs =
    let
      n = pipe config.flake.nixosConfigurations [
        attrsToList
        length
        builtins.toString
      ];
    in
    "- ${n} NixOS configs";

  perSystem =
    { pkgs, lib, ... }:
    {
      devshells.default.commands = [
        {
          name = "update-os";
          help = "Switch to new NixOS configuration";
          command = "${lib.getExe pkgs.nh} os switch";
        }
      ];
    };
}
