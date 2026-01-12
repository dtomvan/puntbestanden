{
  flake.modules.nixos.networking-wifi-passwords =
    { config, lib, ... }:
    let
      inherit (config.networking) hostName;
      hostInterfaces = {
        feather = "wlp0s20f3";
        boomer = "wlp7s0";
      };
      makeSimpleNetwork =
        {
          ssid,
          user ? "tomvd",
          uuid,
          interface ? hostInterfaces."${hostName}" or null,
          ...
        }:
        lib.nameValuePair ssid {
          connection = {
            id = ssid;
            interface-name = interface;
            permissions = "user:${user}:;";
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
            ssid = "\${psk_${ssid}}";
          };
          wifi-security = {
            auth-alg = "open";
            key-mgmt = "wpa-psk";
            leap-password-flags = "1";
            psk-flags = "1";
            wep-key-flags = "1";
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
          lib.pipe
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
            [ (builtins.map makeSimpleNetwork) lib.listToAttrs ];
      };
    };
}
