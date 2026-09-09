let
  inherit (import ../_consts.nix) domain;
in
{
  flake.modules.nixos.services-url =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.infra.url;

      inherit (lib)
        mkDefault
        mkEnableOption
        mkPackageOption
        mkIf
        mkOption
        mkMerge
        singleton
        ;

      inherit (lib.types)
        port
        str
        ;
    in
    {
      options.infra.url = {
        enable = mkEnableOption "chhoto-url";
        package = mkPackageOption pkgs "chhoto-url" { };

        nginx = {
          enable = mkEnableOption "use nginx";

          port = mkOption {
            default = 4567;
            type = port;
          };

          domain = mkOption {
            type = str;
            default = "u.${domain}";
          };
        };
      };

      config = mkMerge [
        {
          sops = {
            secrets.chhoto-env = {
              mode = "0400";
              sopsFile = ../../secrets/chhoto-env.secret;
              format = "binary";
              owner = "root";
            };
          };
        }
        (mkIf cfg.enable {
          services.chhoto-url = {
            enable = true;
            environmentFiles = singleton config.sops.secrets.chhoto-env.path |> mkDefault;
            settings = {
              port = mkIf cfg.nginx.enable cfg.nginx.port;
              site_url = mkIf cfg.nginx.enable "https://${cfg.nginx.domain}";
            };
          };

          services.nginx.virtualHosts."${cfg.nginx.domain}" = mkIf cfg.nginx.enable {
            enableACME = true;
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://localhost:${toString cfg.nginx.port}";
              proxyWebsockets = true;
              extraConfig = ''
                client_max_body_size 0;
                proxy_buffering off;
                proxy_request_buffering off;
                proxy_buffers 32 8k;
                proxy_buffer_size 16k;
                proxy_busy_buffers_size 24k;
              '';
            };
          };
        })
      ];
    };
}
