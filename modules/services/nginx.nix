{ inputs, lib, ... }:
{
  flake.modules.nixos.services-nginx =
    { pkgs, config, ... }:
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
            realIps =
              file:
              builtins.readFile file
              |> lib.splitString "\n"
              |> lib.concatMapStringsSep "\n" (x: "set_real_ip_from  ${x};");

            v4 = pkgs.fetchurl {
              url = "https://www.cloudflare.com/ips-v4";
              hash = "sha256-8Cxtg7wBqwroV3Fg4DbXAMdFU1m84FTfiE5dfZ5Onns=";
            };

            v6 = pkgs.fetchurl {
              url = "https://www.cloudflare.com/ips-v6";
              hash = "sha256-np054+g7rQDE3sr9U8Y/piAp89ldto3pN9K+KCNMoKk=";
            };
          in
          ''
            ${realIps v4}
            ${realIps v6}
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
