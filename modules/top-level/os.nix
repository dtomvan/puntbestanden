{
  self,
  inputs,
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

  inherit (self) hosts;

  makeNixos =
    _key: host:
    nameValuePair host.hostName (nixosSystem {
      modules = [
        (self.lib.system host.system)
        { networking = { inherit (host) hostName; }; }
        self.modules.nixos."hosts-${host.hostName}"
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
      n = pipe self.nixosConfigurations [
        attrsToList
        length
        builtins.toString
      ];
    in
    "- ${n} NixOS configs (well, this is a generated number to it's technically correct but don't over-estimate me)";

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
