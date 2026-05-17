let
  inherit (import ../_consts.nix) domain;
in
{ self, lib, ... }:
{
  hosts.hetzner1 = {
    description = "Hetzner bakkie for my own Forgejo instance";
    system = "x86_64-linux";
    users = [ "tomvd" ];
    networking = {
      hostName = "commitit";
      endpoint = "2a01:4f8:1c18:5b92::/64";
      wireguard = {
        enable = true;
        endpoint = "[2a01:4f8:1c18:5b92::1]:51820";
        ips = [
          "2001:db8:1234:ffff::1:3/128"
          "10.0.0.3/32"
        ];
      };
    };
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
          services-copyparty
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

      infra.copy = {
        enable = true;
        enableRecommendedSettings = true;
        package = pkgs.copyparty.override {
          withFTP = false;
          withHashedPasswords = false;
          withMediaProcessing = false;
          withThumbnails = false;
        };
        nginx.enable = true;
        paste.enable = true;
      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
      };

      services.copyparty = {
        settings.e2dsa = lib.mkForce false;
      };

      system.stateVersion = "26.11";
    };
}
