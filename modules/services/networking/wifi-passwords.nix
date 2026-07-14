{ self, lib, ... }:
let
  inherit (lib)
    listToAttrs
    mkOption
    mkOptionDefault
    nameValuePair
    ;
  inherit (lib.types) listOf submodule str;

  networkModule.options = {
    ssid = mkOption {
      description = "wifi.ssid in nmconnection";
      type = str;
    };
    uuid = mkOption {
      description = "connection.uuid in nmconnection";
      type = str;
    };
  };
in
{
  options.flake.wifi-networks = mkOption {
    description = "";
    type = listOf (submodule networkModule);
    default = [ ];
  };

  config.flake.wifi-networks = mkOptionDefault [
    {
      ssid = "H369A8D363E";
      uuid = "edc1c000-5e83-41fb-a64e-b2814a532d9e";
    }
    {
      ssid = "BWA-6A0F06";
      uuid = "787845e2-1f4a-4f3e-b85b-4a8ba80dceb9";
    }
    {
      ssid = "ASUS_D0_5G";
      uuid = "6d2cf195-4351-40e8-ab61-e2e6acf60767";
    }
  ];

  config.flake.modules.nixos.networking-wifi-passwords =
    {
      config,
      host ? null,
      ...
    }:
    let
      makeSimpleNetwork =
        {
          ssid,
          uuid,
          interface ? host.networking.wirelessInterface or null,
          ...
        }:
        nameValuePair ssid {
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
          };
        };

      makeNmSecret =
        { ssid, ... }:
        {
          matchId = ssid;
          # wifi{,-security} -> 802-11-wireless{,-security} resp. for some reason
          matchType = "802-11-wireless";
          matchSetting = "802-11-wireless-security";
          key = "psk";
          file = config.sops.secrets.${ssid}.path;
        };

      makeSopsSecret =
        { ssid, ... }:
        nameValuePair ssid {
          mode = "0400";
          sopsFile = ../../../secrets/wifi.yaml;
          format = "yaml";
          owner = "root";
          group = "root";
        };
    in
    {
      sops.secrets =
        (self.wifi-networks ++ [ { ssid = "eduroam"; } ]) |> map makeSopsSecret |> listToAttrs;

      networking.networkmanager.ensureProfiles = {
        secrets.entries = (self.wifi-networks |> map makeNmSecret) ++ [
          {
            matchId = "eduroam";
            matchType = "802-11-wireless";
            matchSetting = "802-1x";
            key = "password";
            file = config.sops.secrets.eduroam.path;
          }
        ];
        profiles = (self.wifi-networks |> map makeSimpleNetwork |> listToAttrs) // {
          eduroam = {
            "802-1x" = {
              anonymous-identity = "anonymous@student.rug.nl"; # TODO: I assumed this, the actual docs say "leave empty"
              ca-cert = "/etc/ssl/certs/ca-bundle.crt"; # use system certs
              domain-suffix-match = "rug.nl";
              eap = "peap";
              identity = "s6771092@student.rug.nl";
              phase2-autheap = "mschapv2";
            };
            connection = {
              id = "eduroam";
              interface-name = host.networking.wirelessInterface or null;
              type = "wifi";
              uuid = "216cd576-39ae-4f3e-b61c-7e236f5fee79";
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
              ssid = "eduroam";
            };
            wifi-security = {
              auth-alg = "open";
              key-mgmt = "wpa-eap";
            };
          };
        };
      };
    };
}
