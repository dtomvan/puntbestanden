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
          in
          ''
            ${realIps}
            real_ip_header CF-Connecting-IP;

            log_format main '$remote_addr - $remote_user [$time_local] '
                            '"$request" $status $body_bytes_sent '
                            '"$http_referer" "$http_user_agent"';

            access_log /var/log/nginx/access.log main;
            error_log /var/log/nginx/error.log warn;
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
    };
}
