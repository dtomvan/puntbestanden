{ config, lib, ... }:
let
  peersHosts =
    client:
    config.hosts
    |> lib.attrValues
    |> builtins.filter (
      host: host.networking.wireguard.enable && (host.networking.hostName != client.networking.hostName)
    );

  peersFor =
    client:
    peersHosts client
    |> builtins.filter (
      host: (host.networking.wireguard.endpoint != null) || (client.networking.wireguard.endpoint != null)
    )
    |> map (host: {
      name = host.networking.hostName;
      inherit (host.networking.wireguard) allowedIPs endpoint publicKey;
      persistentKeepalive = 25;
    });

  hostsFor =
    host:
    peersHosts host
    |> map (host: {
      name =
        builtins.elemAt host.networking.wireguard.ips 0 |> lib.splitString "/" |> (s: builtins.elemAt s 0);
      value = [ host.networking.hostName ];
    })
    |> lib.listToAttrs;
in
{
  flake.modules.nixos.networking-wireguard =
    { config, host, ... }:
    let
      cfg = host.networking.wireguard;
      inherit (config.networking.wireguard) useNetworkd;
    in
    {
      config = lib.mkIf cfg.enable {
        boot.kernel.sysctl = {
          "net.ipv4.ip_forward" = 1;
          "net.ipv4.conf.all.forwarding" = 1;
          "net.ipv6.conf.all.forwarding" = 1;
        };

        networking = {
          firewall = {
            allowedUDPPorts = [ cfg.listenPort ];
            trustedInterfaces = [ "wg0" ];
          };
          useNetworkd = lib.mkDefault true;
          wireguard = {
            enable = true;
            interfaces.wg0 = {
              inherit (cfg) ips listenPort;
              peers = peersFor host;
              privateKeyFile = config.sops.secrets.wireguard-privkey.path;
            };
          };
          hosts = hostsFor host;
        };

        sops = {
          useSystemdActivation = lib.mkForce true;

          secrets.wireguard-privkey = {
            format = "binary";
            sopsFile = ../../../secrets/wireguard/${config.networking.hostName}.secret;
            mode = lib.mkIf useNetworkd "640";
            owner = lib.mkIf useNetworkd "systemd-network";
            group = lib.mkIf useNetworkd "systemd-network";
            restartUnits = lib.mkIf useNetworkd [ "systemd-networkd.service" ];
          };
        };

        systemd.services.systemd-networkd = lib.mkIf useNetworkd {
          requires = [ "sops-install-secrets.service" ];
          after = [ "sops-install-secrets.service" ];
        };
      };
    };

  perSystem =
    { pkgs, self', ... }:
    {
      packages.genwg = pkgs.writeShellApplication {
        name = "genwg";
        runtimeInputs = builtins.attrValues {
          inherit (pkgs)
            hostname-debian
            iproute2
            wireguard-tools
            sops
            gitMinimal
            ;
        };
        text = ''
          hostname="''${1:-$(hostname)}"
          pushd "$(git rev-parse --show-toplevel)"
          mkdir -p secrets/wireguard
          wg genkey | tee "secrets/wireguard/$hostname.secret" | wg pubkey > "secrets/wireguard/$hostname.pub"
          sops encrypt --in-place "secrets/wireguard/$hostname.secret"
        '';
      };
      devshells.default.packages = [ self'.packages.genwg ];
    };
}
