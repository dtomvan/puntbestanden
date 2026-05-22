# nginx stuff: dedup as lib.mkNginxModule???

- STATE: OPEN
- PRIORITY: 50
- TAGS: 

../../modules/services/miniflux.nix

This happens a lot:

```nix
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
```

Followed by:

```nix
          systemd.sockets.miniflux = mkIf cfg.nginx.enable {
            before = [ "nginx.service" ];
            wantedBy = [ "sockets.target" ];
            socketConfig = {
              ListenStream = cfg.nginx.unixSocket;
              SocketUser = config.systemd.services.miniflux.user;
              SocketGroup = config.systemd.services.miniflux.group;
              SocketMode = "770";
            };
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
```
