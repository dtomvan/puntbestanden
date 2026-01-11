{
  flake.modules.nixos.networking-wifi-passwords =
    { config, ... }:
    {
      sops.secrets.wifi-passwords = {
        mode = "0440";
        sopsFile = ../../../secrets/wifi-passwords.secret;
        format = "binary";
        owner = "wpa_supplicant";
        group = "wpa_supplicant";
      };

      networking.wireless = {
        allowAuxiliaryImperativeNetworks = true;
        userControlled = true;
        secretsFile = config.sops.secrets.wifi-passwords.path;
        networks = {
          H369A8D363E.pskRaw = "ext:psk_H369A8D363E";
          BWA-6A0F06.pskRaw = "ext:psk_BWA-6A0F06";
        };
      };
    };
}
