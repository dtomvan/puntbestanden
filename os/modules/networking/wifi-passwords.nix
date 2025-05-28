{ config, ... }:
{
  sops.secrets.wifi-passwords = {
    mode = "0440";
    sopsFile = ../../../secrets/wifi-passwords.secret;
    format = "binary";
    # wpa_supplicant gets run as root so no-one else has to read the cleartext passwords
    owner = "root";
    group = "wheel";
  };

  networking.wireless = {
    secretsFile = config.sops.secrets.wifi-passwords.path;
    networks = {
      H369A8D363E.pskRaw = "ext:psk_H369A8D363E";
      BWA-6A0F06.pskRaw = "ext:psk_BWA-6A0F06";
    };
  };
}
