{ self, ... }:
{
  flake.modules.nixos.pinchflat =
    { config, lib, ... }:
    {
      imports = [ self.modules.nixos.sops ];

      sops.secrets.pinchflat = {
        mode = "0400";
        sopsFile = ../../secrets/pinchflat.secret;
        format = "binary";
        owner = config.services.pinchflat.user;
        inherit (config.services.pinchflat) group;
      };

      services.pinchflat = {
        enable = true;
        secretsFile = config.sops.secrets.pinchflat.path;
        extraConfig = {
          ENABLE_IPV6 = true;
          EXPOSE_FEED_ENDPOINTS = true;
        };
      };

      services.${if config.services ? copyparty then "copyparty" else null} = {
        volumes."/pinchflat" = {
          path = config.services.pinchflat.mediaDir;
          access.r = "*";
          flags = {
            e2ts = true;
            dthumb = true;
          };
        };
      };

      systemd.tmpfiles.settings."10-pinchflat" = lib.mkIf config.services.syncthing.enable {
        "/var/lib/pinchflat/media/.stfolder" = {
          d = {
            inherit (config.services.pinchflat) group user;
            mode = "0755";
          };
        };
      };
    };
}
