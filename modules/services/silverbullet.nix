{
  flake.modules.nixos.services-silverbullet =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      cfg = config.infra.silverbullet;
      inherit (lib)
        types
        mkEnableOption
        mkPackageOption
        mkOption
        mkIf
        mkMerge
        ;
      inherit (types) str port;
    in
    {
      options.infra.silverbullet = {
        enable = mkEnableOption "silverbullet";
        enableEdge = mkEnableOption "edge channel thru podman";
        package = mkPackageOption pkgs "silverbullet" { };

        silverbulletPort = mkOption {
          type = port;
          default = 5472;
        };

        domain = mkOption {
          type = str;
          default = "sb.${(import ../_consts.nix).domain}";
        };
      };

      config = mkMerge [
        {
          services.nginx.virtualHosts."${cfg.domain}" = mkIf cfg.enable {
            enableACME = true;
            forceSSL = true;
            locations."/".proxyPass = "http://127.0.0.1:${toString cfg.silverbulletPort}";
          };
        }
        (mkIf (!cfg.enableEdge) {
          services.silverbullet = {
            inherit (cfg) enable package;

            listenPort = cfg.silverbulletPort;
          };

          systemd.services.silverbullet.path = [
            pkgs.gitMinimal
            pkgs.openssh
          ];
        })
        (mkIf cfg.enableEdge {
          virtualisation.oci-containers.containers.silverbullet = {
            image = "ghcr.io/silverbulletmd/silverbullet:edge-slim";
            pull = "newer";
            ports = [
              "${toString cfg.silverbulletPort}:3000"
            ];
            volumes = [
              "${config.services.silverbullet.spaceDir}:/data"
            ];
          };
        })
      ];
    };
}
