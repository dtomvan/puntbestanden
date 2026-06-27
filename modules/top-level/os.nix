{
  self,
  config,
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
    ;

  inherit (config) hosts;

  makeNixos =
    _key: host:
    nameValuePair host.networking.hostName (nixosSystem {
      modules = [
        (self.lib.system host.system)
        { networking = { inherit (host.networking) hostName; }; }
        self.modules.nixos."hosts-${host.networking.hostName}"
        self.modules.nixos.common-options
        ../hardware/_generated/${host.networking.hostName}.nix
      ]
      ++ (map (u: self.modules.nixos."users-${u}") host.users);
      specialArgs = { inherit host; };
    });
in
{
  flake.nixosConfigurations =
    hosts |> filterAttrs (_k: v: hasInfix "linux" v.system && v.hasConfig) |> mapAttrs' makeNixos;

  text.readme.parts.nixos_configs =
    let
      n =
        self.nixosConfigurations
        |> attrsToList
        |> length
        |> toString;
    in
    "- ${n} NixOS configs (well, this is a generated number so it's technically correct but don't over-estimate me)";
}
