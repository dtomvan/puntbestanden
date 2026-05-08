{
  flake.modules.nixos.networking-wifi-passwords =
    {
      config,
      lib,
      host ? null,
      ...
    }:
    let
      makeSimpleNetwork =
        {
          ssid,
          uuid,
          interface ? host.wirelessInterface or null,
          ...
        }:
        lib.nameValuePair ssid {
          connection = {
            id = ssid;
            interface-name = interface;
            type = "wifi";
            inherit uuid;
          };
          ipv4 = {
            method = "auto";
          };
          ipv6 = {
            addr-gen-mode = "default";
            method = "auto";
          };
          proxy = { };
          wifi = {
            mode = "infrastructure";
            inherit ssid;
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            psk = "$psk_${ssid}";
          };
        };
    in
    {
      sops.secrets.wifi-passwords = {
        mode = "0440";
        sopsFile = ../../../secrets/wifi-passwords.secret;
        format = "binary";
        owner = "root";
        group = "root";
      };

      networking.networkmanager.ensureProfiles = {
        environmentFiles = lib.singleton config.sops.secrets.wifi-passwords.path;
        profiles =
          [
            {
              ssid = "H369A8D363E";
              uuid = "edc1c000-5e83-41fb-a64e-b2814a532d9e";
            }
            {
              ssid = "BWA-6A0F06";
              uuid = "787845e2-1f4a-4f3e-b85b-4a8ba80dceb9";
            }
          ]
          |> map makeSimpleNetwork
          |> lib.listToAttrs;
      };
    };
}
