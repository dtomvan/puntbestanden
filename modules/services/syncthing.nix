{ config, ... }:
{
  flake.modules.nixos.services-syncthing =
    let
      inherit (config.flake) hosts;

      username = "tomvd";
      devices = {
        ${hosts.hp3600.hostName} = {
          id = "SMIZJNY-VQPDQQT-Q3QUAXW-5WBVOFS-QVRBNYM-CTM4FW5-XT656EE-IYXOQAZ";
          autoAcceptFolders = true;
        };
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
      };
    in
    {
      services.syncthing = {
        enable = true;
        # no own group
        group = "users";
        user = username;
        dataDir = "/home/${username}";

        settings = {
          inherit devices folders;

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

  flake.modules.homeManager.syncthing =
    { pkgs, lib, ... }:
    {
      xdg.desktopEntries.syncthing-shortcut = {
        name = "Syncthing";
        comment = "Open syncthing in browser";
        icon = "Syncthing";
        exec = "${lib.getExe' pkgs.xdg-utils "xdg-open"} http://127.0.0.1:8384/";
        categories = [ "Utility" ];
      };
    };
}
