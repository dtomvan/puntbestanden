{
  pkgs,
  lib,
  config,
  ...
}: let
  hostname = config.networking.hostName;
  username = "tomvd";
  devices = {
    tom-pc = {
      id = "3QIVELR-TAOILMZ-446OGI4-76UTNJD-ZA67C4P-X532YOE-ONJS5RY-LWY6HQZ";
      autoAcceptFolders = true;
    };
    tom-laptop = {
      id = "FZXZUK4-65AZIHQ-OW3ORI7-FTXCU43-6HMDWDR-CBDZCKD-ECM22MD-MWULWQD";
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
  };
in {
  services.syncthing = {
    enable = true;
    # no own group
    group = "users";
    user = username;
    dataDir = "/home/${username}";

    key = (builtins.toString ../../st-keys) + "/${hostname}.key.pem";
    cert = (builtins.toString ../../st-keys) + "/${hostname}.cert.pem";

    settings = {
      inherit devices folders;

      gui = {
        # Yes, this is the option name
        enabled = true;
        user = username;
        password = "$2a$10$bYZG2XbEoOuRxX4A1e46cOIvTgoPfLQRGa4fKnqAI1L8vwMfdB0ri";
        apiKey = "mWDXydDdFfhEu7XkyAvWRS26Kdt4D6zD";
      };

      options = {
        urAccepted = 3;
      };
    };
  };
}
