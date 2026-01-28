toplevel@{ self, lib, ... }:
{
  flake.modules.nixos.services-syncthing =
    { config, ... }:
    let
      inherit (toplevel.config) hosts;

      username = "tomvd";
      devices = {
        ${hosts.amdpc1.hostName} = {
          id = "3QIVELR-TAOILMZ-446OGI4-76UTNJD-ZA67C4P-X532YOE-ONJS5RY-LWY6HQZ";
          autoAcceptFolders = true;
        };
        ${hosts.tpx1g8.hostName} = {
          id = "2TCHDIM-XCWIBM4-5DL2EK6-7Y7VOSO-TOSZYG6-JNYQYFU-PONSM2D-X2CITQT";
          autoAcceptFolders = true;
        };
        a52 = {
          id = "3P4JOUH-NHDCUVU-I2QGOZ6-LNV7CPI-RMMZQEA-ZW3HR7X-LI46MSB-N7UIYQP";
          autoAcceptFolders = false;
        };
      };
      allDevices = builtins.attrNames devices;
      folders = {
        default = {
          path = "~/Sync";
          devices = allDevices;
        };
        Documents = {
          id = "kmfc4-cvogr";
          path = "~/Documents";
          devices = allDevices;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "90";
          };
        };
        Pictures = {
          id = "xzsp4-pibte";
          path = "~/Pictures";
          devices = allDevices;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        Music = {
          id = "pmac7-de6gr";
          path = "~/Music";
          devices = allDevices;
          versioning = {
            type = "trashcan";
            params.cleanoutDays = "30";
          };
        };
        pinchflat = lib.mkIf config.services.pinchflat.enable {
          id = "g7kr4-ewyfn";
          path = "/var/lib/pinchflat/media";
          devices = allDevices;
          type = "sendonly";
        };
      };
    in
    {
      imports = with self.modules.nixos; [
        sops
      ];

      sops.secrets.syncthing = {
        mode = "0400";
        sopsFile = ../../../secrets/syncthing.${config.networking.hostName}.secret;
        format = "binary";
        owner = config.services.syncthing.user;
        inherit (config.services.syncthing) group;
      };

      services.syncthing = {
        enable = true;
        # no own group
        group = "users";
        user = username;
        dataDir = "/home/${username}";

        extraFlags = [ "--allow-newer-config" ];

        settings = {
          inherit devices folders;

          # if unset, after reinstallation of syncthing (or deleting configDir)
          # you'd get new device IDs. This way I hope to keep them for a little
          # longer.
          cert = _pubkeys/${config.networking.hostName}.pem;
          key = config.sops.secrets.syncthing.path;

          gui = {
            # Yes, this is the option name
            enabled = true;
            user = username;
            password = "$2a$10$bYZG2XbEoOuRxX4A1e46cOIvTgoPfLQRGa4fKnqAI1L8vwMfdB0ri";
          };

          options = {
            urAccepted = 3;
          };
        };
      };
    };
}
