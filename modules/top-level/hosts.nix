{ config, lib, ... }:
# How to add a host
# 1. Create a file (usually in modules/hosts/) that sets
#    `flake.modules.nixos.hosts-foobar` and `hosts.foobar`
# 2. nixos-generate-config --show-hardware-config > modules/hardware/_generated/foobar.nix
# minimal hosts entry:
# {
#   hosts.foobar = {
#     system = "x86_64-linux";
#     users = [ ];
#     mainDisk = "/dev/disk/by-id/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
#     networking.hostName = "foobar";
#   };
# }
let
  inherit (lib)
    attrValues
    concatLines
    concatMapStringsSep
    filter
    mkEnableOption
    mkOption
    trim
    ;
  inherit (lib.types)
    attrsOf
    bool
    listOf
    nullOr
    port
    raw
    str
    strMatching
    submodule
    ;

  remoteBuildModule.options = {
    enable = mkEnableOption "remote building ON that machine (that is, the given machine becomes a TARGET for remote building)";
    settings = mkOption {
      description = "Settings passed to the generated entry in `nix.buildMachines'";
      type = attrsOf raw;
      default = { };
      example = {
        maxJobs = 1;
      };
    };
  };

  keyModule.options = {
    key = mkOption {
      description = "ssh public key (from ssh-keyscan) to allow";
      type = str;
      default = null;
    };
    allowedHosts = mkOption {
      description = "which hosts are allowed to be reached, by hostname";
      type = listOf str;
      default = [ ];
    };
    allowedUsers = mkOption {
      description = "which users are allowed to be reached, by username";
      type = listOf str;
      default = [ ];
    };
  };

  networkingModule =
    { config, ... }:
    {
      options = {
        hostName = mkOption {
          description = "What the value of `networking.hostName' will be";
          type = str;
          example = "elated-minsky";
        };

        wirelessInterface = mkOption {
          description = "Interface name where NetworkManager profiles are set";
          # TODO: is this pattern accurate?
          type = nullOr (strMatching "^(en|wl)p[0-9a-f]+s[0-9a-f]+$");
          default = null;
          example = "wlp7s0";
        };

        endpoint = mkOption {
          type = nullOr str;
          default = null;
        };

        wireguard = {
          enable = mkEnableOption "wireguard";

          publicKey = mkOption {
            type = str;
            default = trim (builtins.readFile ../../secrets/wireguard/${config.hostName}.pub);
          };

          listenPort = mkOption {
            type = port;
            default = 51820;
          };

          endpoint = mkOption {
            type = nullOr str;
            default = null;
          };

          ips = mkOption {
            type = listOf str;
            default = [ ];
          };

          allowedIPs = mkOption {
            type = listOf str;
            default = config.wireguard.ips;
          };
        };
      };
    };

  hostModule.options = {
    description = mkOption {
      description = "A description of what the hardware is, where the system is located, or a reminder about which system the host is referring to";
      type = str;
      default = "No description set.";
      example = "That one Hetzner box";
    };
    system = mkOption {
      description = "What the value of `nixpkgs.hostPlatform' will be";
      type = str;
      example = "x86_64-linux";
    };
    users = mkOption {
      description = "List of normal users to add *and* to instantiate a HM config for";
      type = listOf str;
      default = [ ];
      example = [
        "tomvd"
        "alice"
      ];
    };
    mainDisk = mkOption {
      description = "Disk where NixOS is installed to (and Disko manages), must be absolute, by-id.";
      # exception for hetzner bakkies
      type = strMatching "^/dev/disk/by-id/.*$" |> nullOr;
      example = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0R412949Y";
    };
    sshPubkey = mkOption {
      description = "Public key that is recognized by other machines in authorized_keys";
      type = nullOr (submodule keyModule);
    };

    networking = mkOption {
      type = submodule networkingModule;
    };

    isNvidiaPascal = mkOption {
      description = "Whether to pin the Nvidia driver to version 580, if applicable";
      type = bool;
      default = false;
    };
    remoteBuild = mkOption {
      description = "Remote build settings";
      type = submodule remoteBuildModule;
    };

    hasConfig = (mkEnableOption "configuring this host for nixos") // {
      default = true;
    };
    hasDoc = (mkEnableOption "listing this hostname in readme.md with its description") // {
      default = true;
    };

    enableHomeManager = mkEnableOption "deploy-rs profiles for home-manager";
    enableMaid = mkEnableOption "deploy-rs profiles for nix-maid";
    enableNixvim = mkEnableOption "deploy-rs profiles for nixvim";
    flatpak = {
      enable = mkEnableOption "deploy-rs profiles that declaratively install some flatpaks";
      packages = mkOption {
        description = "list of pre-installed flatpak apps";
        type = listOf str;
        default = [
          "com.github.tchx84.Flatseal"
          "io.github.kolunmi.Bazaar"
        ];
        example = [
          "org.kde.okular"
          "com.discordapp.Discord"
        ];
      };
    };

    extraScrapeConfigs = mkOption {
      description = "Scrape configs to be picked up by prometheus";
      default = { };
      type =
        submodule {
          options = {
            port = mkOption {
              type = port;
            };
          };
        }
        |> attrsOf;
    };
  };
in
{
  options.hosts = mkOption {
    description = "an inventory of all systems configured using this flake";
    type = attrsOf (submodule hostModule);
    default = { };
  };

  config = {
    perSystem =
      { pkgs, self', ... }:
      let
        mkPerhost =
          { name, mapper }:
          pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = [ pkgs.nur.repos.dtomvan.sshp ];
            runtimeEnv.hosts = config.hosts |> attrValues |> concatMapStringsSep "\n" mapper;
            text = ''
              echo Will execute: "$*"
              echo On these hosts:
              echo "$hosts"
              read -r -n 1 -p 'is this okay? [yN]' choice
              if [[ "$choice" =~ [yY] ]]; then
                sshp -f <(printf '%s\n' "''${hosts:?}") "$@"
              fi
            '';
          };
      in
      {
        legacyPackages.hosts = builtins.toFile "hosts.json" (builtins.toJSON config.hosts);
        devshells.default.packages = [
          self'.packages.perhost
          self'.packages.perroot
        ];
        packages.perroot = mkPerhost {
          name = "perroot";
          mapper = h: "root@${h.networking.hostName}";
        };
        packages.perhost = mkPerhost {
          name = "perhost";
          mapper = h: h.networking.hostName;
        };
      };

    text.readme.parts.hostnames = ''
      ## The hostnames

    ''
    + (
      config.hosts
      |> attrValues
      |> filter (h: h.hasDoc)
      |> map (h: "- `${h.networking.hostName}`, ${h.description}")
      |> concatLines
    );
  };
}
