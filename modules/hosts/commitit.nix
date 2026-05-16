let
  inherit (import ../_consts.nix) domain;
in
{ self, ... }:
{
  hosts.hetzner1 = {
    description = "Hetzner bakkie for my own Forgejo instance";
    hostName = "commitit";
    system = "x86_64-linux";
    users = [ "tomvd" ];
  };

  flake.modules.nixos.hosts-commitit =
    { pkgs, ... }:
    {
      imports = builtins.attrValues {
        inherit (self.modules.nixos)
          profiles-hetzner-bakkie
          hardware-hetzner-cloud
          lets-encrypt
          services-forgejo
          ;
      };

      infra.fj = {
        enable = true;
        lfsSupport = true;
        domain = "git.${domain}";
        admin = {
          enable = true;
          name = "tomvd";
        };
        actions.enable = true;
      };

      # FIXME: Hetzner Cloud doesn't provide us with that configuration
      systemd.network.networks."10-uplink".networkConfig.Address = "2a01:4f8:1c18:5b92::/64";

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
      };

      system.stateVersion = "26.11";
    };
}
