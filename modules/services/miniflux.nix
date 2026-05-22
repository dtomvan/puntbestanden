let
  inherit (import ../_consts.nix) domain;
in
{
  flake.modules.nixos.services-miniflux =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.infra.miniflux;

      inherit (lib)
        mkDefault
        mkEnableOption
        mkPackageOption
        mkIf
        mkOption
        mkMerge
        ;

      inherit (lib.types)
        str
        passwdEntry
        attrsOf
        raw
        ;
    in
    {
      options.infra.miniflux = {
        enable = mkEnableOption "miniflux";
        package = mkPackageOption pkgs "miniflux" { };

        group = mkOption {
          type = passwdEntry str;
          default = if cfg.nginx.enable then "nginx" else "miniflux";
        };

        # TASK(20260522-170426): dedup as lib.mkNginxModule???
        nginx = {
          enable = mkEnableOption "don't open a port, use nginx instead";

          unixSocket = mkOption {
            description = "socket that both nginx and miniflux agree on to proxy the service";
            type = str;
            default = "/run/miniflux.sock";
          };

          domain = mkOption {
            type = str;
            default = "rss.${domain}";
          };

          extraVirtualHostSettings = mkOption {
            type = attrsOf raw;
            default = { };
          };
        };

        admin = {
          username = mkOption {
            type = str;
            default = "tom";
          };
          password = mkOption {
            description = "Should be sops placeholder";
            type = str;
            default = config.sops.placeholder.miniflux-default-password;
          };
        };
      };

      config = mkMerge [
        {
          sops = {
            secrets.miniflux-default-password = {
              mode = "0400";
              sopsFile = ../../secrets/miniflux-default-password.secret;
              format = "binary";
              owner = "miniflux"; # hardcoded in nixos
              inherit (cfg) group;
            };

            templates.miniflux-default-credentials.content = ''
              ADMIN_USERNAME=${cfg.admin.username}
              ADMIN_PASSWORD=${cfg.admin.password}
            '';
          };
        }
        (mkIf cfg.enable {
          services.miniflux = {
            enable = true;
            adminCredentialsFile = mkDefault config.sops.templates.miniflux-default-credentials.path;
            config = {
              LISTEN_ADDR = mkDefault cfg.nginx.unixSocket |> mkIf cfg.nginx.enable;
              BASE_URL = mkDefault "https://${cfg.nginx.domain}" |> mkIf cfg.nginx.enable;
            };
          };

          systemd.sockets.miniflux = mkIf cfg.nginx.enable {
            before = [ "nginx.service" ];
            wantedBy = [ "sockets.target" ];
            socketConfig = {
              ListenStream = cfg.nginx.unixSocket;
              SocketUser = "miniflux";
              SocketGroup = cfg.group;
              SocketMode = "770";
            };
          };

          systemd.services.miniflux.serviceConfig = {
            DynamicUser = lib.mkForce false;
            User = lib.mkForce "miniflux";
            Group = lib.mkForce cfg.group;
          };

          users.users.miniflux = {
            isSystemUser = true;
            inherit (cfg) group;
          };

          services.nginx.virtualHosts."${cfg.nginx.domain}" = mkIf cfg.nginx.enable {
            enableACME = true;
            forceSSL = true;
            locations."/" = {
              proxyPass = "http://unix://${cfg.nginx.unixSocket}";
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
