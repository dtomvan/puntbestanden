let
  inherit (import ../_consts.nix) domain;
in
{ self, ... }:
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
        endpoint = "91.98.231.12:51820";
        allowedIPs = [
          "10.0.0.0/24"
          "fd42:42:42::/64"
        ];
        ips = [
          "10.0.0.3/32"
          "fd42:42:42::3/128"
        ];
      };
    };
  };

  flake.modules.nixos.hosts-commitit =
    { pkgs, ... }:
    {
      imports = builtins.attrValues {
        inherit (self.modules.nixos)
          # keep-sorted start
          hardware-hetzner-cloud
          lets-encrypt
          profiles-hetzner-bakkie
          services-blog
          services-copyparty
          services-forgejo
          services-hedgedoc
          services-matrix
          services-mautrix-telegram
          services-miniflux
          services-monitoring
          services-readeck
          services-syncthing
          services-vaultwarden
          services-xandikos
          themes-catppuccin
          # keep-sorted end
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
        signing.enable = true;
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
        paste = {
          enable = true;
          extraFlags.vmaxb = "200m";
        };
        scrot = {
          enable = true;
          extraFlags.vmaxb = "2g";
        };
      };

      infra.matrix = {
        enable = true;
        telegram.enable = true;
      };

      services.matrix-continuwuity.package = pkgs.matrix-continuwuity.overrideAttrs (
        final: _prev: {
          version = "0-unstable-2026-09-01";
          src = pkgs.fetchFromGitea {
            domain = "forgejo.ellis.link";
            owner = "continuwuation";
            repo = "continuwuity";
            rev = "62822febfebeec41e905237b14bbeb586f280283";
            hash = "sha256-U5bhe1PyGyIBc1SvNjgOt5IBA41SSlH1OIHOF0Vx/vY=";
          };
          cargoHash = null;
          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            inherit (final) pname version src;
            hash = "sha256-cdbKkjwpKHuBABeXY/qlWD7alH74nLPnkkpTXH+9WrY=";
          };
        }
      );

      infra.md.enable = true;

      infra.miniflux = {
        enable = true;
        nginx.enable = true;
      };

      infra.monitoring = {
        prometheus.enable = true;
        alertmanager.enable = true;
      };

      infra.readeck.enable = true;
      infra.vaultwarden.enable = true;

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
      };

      system.stateVersion = "26.11";
    };
}
