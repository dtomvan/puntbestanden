{ inputs, lib, ... }:
{
  flake.modules.nixos.services-nginx =
    { config, ... }:
    {
      imports = [ inputs.srvos.nixosModules.mixins-nginx ];

      services.nginx = {
        enable = true;
        enableReload = true;

        recommendedBrotliSettings = true;
        recommendedGzipSettings = true;
        recommendedOptimisation = true;
        recommendedProxySettings = true;
        recommendedTlsSettings = true;
        statusPage = true;

        clientMaxBodySize = "128m";

        defaultListenAddresses = [
          "0.0.0.0"
          "[::0]"
        ];

        commonHttpConfig =
          let
            realIps = lib.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};") [
              "173.245.48.0/20"
              "103.21.244.0/22"
              "103.22.200.0/22"
              "103.31.4.0/22"
              "141.101.64.0/18"
              "108.162.192.0/18"
              "190.93.240.0/20"
              "188.114.96.0/20"
              "197.234.240.0/22"
              "198.41.128.0/17"
              "162.158.0.0/15"
              "104.16.0.0/13"
              "104.24.0.0/14"
              "172.64.0.0/13"
              "131.0.72.0/22"
              "2400:cb00::/32"
              "2606:4700::/32"
              "2803:f800::/32"
              "2405:b500::/32"
              "2405:8100::/32"
              "2a06:98c0::/29"
              "2c0f:f248::/32"
            ];
            reqLimitZoneName = "reqlimit";
            connLimitZoneName = "connlimit";
          in
          # nginx
          ''
            ${realIps}
            real_ip_header CF-Connecting-IP;

            log_format main '$remote_addr - $remote_user [$time_iso8601] '
                            '$host "$request" $status $body_bytes_sent '
                            '"$http_referer" "$http_user_agent" '
                            '($request_id)';

            access_log /var/log/nginx/access.log main;
            error_log /var/log/nginx/error.log warn;

            geo $whitelist {
              default 0;
              127.0.0.0/24 1;
              ${lib.optionalString config.networking.wireguard.enable "10.0.0.0/8 1;"}
            }

            map $whitelist $limit {
              0 $binary_remote_addr;
              1 "";
            }

            limit_conn_zone      $limit    zone=${connLimitZoneName}:10m;
            limit_conn           ${connLimitZoneName} 1000;
            limit_conn_log_level warn;
            limit_conn_status    429;

            limit_req_zone $limit zone=${reqLimitZoneName}:10m rate=20r/s;
            limit_req_log_level warn;
            limit_req_status     429;
            limit_req zone=${reqLimitZoneName} burst=100 nodelay;

            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
          '';
      };

      services.fail2ban = {
        enable = true;
        ignoreIP = lib.optionals config.networking.wireguard.enable [ "10.0.0.0/24" ];

        jails = {
          nginx-http-auth = ''
            enabled = true
            filter = nginx-http-auth
            logpath = /var/log/nginx/error.log
            maxretry = 5
          '';

          nginx-badbots = ''
            enabled = true
            filter = nginx-badbots
            logpath = /var/log/nginx/access.log
            maxretry = 2
          '';
        };
      };

      services.prometheus.exporters.nginx.enable = lib.mkDefault true;
      services.prometheus.exporters.nginxlog = {
        enable = lib.mkDefault true;
        # why isn't this the default????
        settings.namespaces =
          lib.singleton {
            name = "default";
            format = ''$remote_addr - $remote_user [$time_iso8601] '$host "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent" ($request_id)'';
            source.files = [
              "/var/log/nginx/access.log"
              "/var/log/nginx/error.log"
            ];
          }
          |> lib.mkDefault;
      };

      # make recent nginx logs available in the journal, but don't keep them.
      # The actual logs are written to /var/log/nginx anyways.
      # TODO: make rfc42-style after https://github.com/NixOS/nixpkgs/pull/455499
      environment.etc."systemd/journald@nginx.conf".text = ''
        [Journal]
        Storage=volatile
        RuntimeMaxUse=10M
      '';

      systemd.services.nginx.serviceConfig.LogNamespace = "nginx";

      systemd.services.prometheus-nginxlog-exporter.serviceConfig.SupplementaryGroups = [ "nginx" ];

      services.logrotate.settings.nginx = {
        # 4 weeks ~= a month, I don't need half a year of logs (default = 26)
        rotate = lib.mkForce 4;
        # compress immediately. I get too much spam not to do that.
        delaycompress = lib.mkForce false;
      };
    };

  flake.modules.nixos.services-monitoring =
    { pkgs, ... }:
    {
      infra.monitoring.grafana.dashboards = lib.singleton (
        pkgs.fetchurl {
          name = "prometheus-nginx-exporter.json";
          url = "https://grafana.com/api/dashboards/14900/revisions/2/download";
          hash = "sha256-9iOEwKdFxOyw2T7Non4k2yUwiajWpH3qgQTyJRrttwM=";
        }
      );
    };
}
