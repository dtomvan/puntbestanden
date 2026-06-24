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
        endpoint = "[2a01:4f8:1c18:5b92::1]:51820";
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
          profiles-hetzner-bakkie
          hardware-hetzner-cloud
          lets-encrypt
          services-forgejo
          services-copyparty
          services-miniflux
          services-monitoring
          services-blog
          services-matrix
          services-mautrix-telegram
          services-hedgedoc
          services-syncthing

          themes-catppuccin
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

      infra.md.enable = true;

      infra.miniflux = {
        enable = true;
        nginx.enable = true;
      };

      infra.monitoring = {
        prometheus.enable = true;
        alertmanager.enable = true;
      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_18;
      };

      system.stateVersion = "26.11";
    };
}
