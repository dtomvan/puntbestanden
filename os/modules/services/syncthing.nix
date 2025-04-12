let
  hosts = import ../../../hosts.nix;
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
    logseq-mobile = {
      id = "xcerk-k5e52";
      path = "~/logseq-mobile";
      devices = allDevices;
    };
  };
in {
  # sops.secrets."tomvd.pass" = {
  #   sopsFile = ../../../secrets/tomvd.pass.secret;
  #
  #   format = "binary";
  #
  #   mode = "0600";
  #   owner = "tomvd";
  #   group = "users";
  # };

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
}
