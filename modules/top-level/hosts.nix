{ config, lib, ... }:
# How to add a host
# 1. Add an entry to this file
# 2. Create a file (usually in modules/hosts/) that sets modules.nixos.`hosts-foobar`
# 3. nixos-generate-config --show-hardware-config > modules/hardware/_generated/foobar.nix
let
  inherit (lib)
    attrValues
    concatLines
    filter
    mkEnableOption
    mkOption
    pipe
    ;
  inherit (lib.types)
    attrsOf
    bool
    listOf
    nullOr
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

  hostModule.options = {
    description = mkOption {
      description = "A description of what the hardware is, where the system is located, or a reminder about which system the host is referring to";
      type = str;
      default = "No description set.";
      example = "That one Hetzner box";
    };
    hostName = mkOption {
      description = "What the value of `networking.hostName' will be";
      type = str;
      example = "elated-minsky";
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
      type = strMatching "^/dev/disk/by-id/.*$";
      example = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0R412949Y";
    };
    wirelessInterface = mkOption {
      description = "Interface name where NetworkManager profiles are set";
      # TODO: is this pattern accurate?
      type = nullOr (strMatching "^(en|wl)p[0-9a-f]+s[0-9a-f]+$");
      default = null;
      example = "wlp7s0";
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
  };
in
{
  options.hosts = mkOption {
    description = "an inventory of all systems configured using this flake";
    type = attrsOf (submodule hostModule);
    default = { };
  };

  config = {
    hosts = {
      amdpc1 = {
        description = "a reasonably sluggish Ryzen 5 2600 desktop PC";
        hostName = "boomer";
        system = "x86_64-linux";
        users = [ "tomvd" ];
        mainDisk = "/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_1TB_S5H9NS0R412949Y";
        wirelessInterface = "wlp7s0";
        isNvidiaPascal = true;
        remoteBuild = {
          enable = true;
          settings = {
            maxJobs = 12;
            supportedFeatures = [
              "benchmark"
              "nixos-test"
              "big-parallel"
              "kvm"
            ];
            speedFactor = 4;
          };
        };
      };

      tpx1g8 = {
        description = "the ultra-light Thinkpad X1 Carbon G8";
        hostName = "feather";
        system = "x86_64-linux";
        users = [ "tomvd" ];
        mainDisk = "/dev/disk/by-id/nvme-2-Power_SSD7015A_1TB_P1360761115";
        wirelessInterface = "wlp0s20f3";
        remoteBuild.enable = true;
      };
    };

    perSystem.legacyPackages.hosts = builtins.toFile "hosts.json" (builtins.toJSON config.hosts);

    text.readme.parts.hostnames = ''
      ## The hostnames

    ''
    + pipe config.hosts [
      attrValues
      (filter (h: !(h ? noDoc)))
      (map (h: "- `${h.hostName}`, ${h.description}"))
      concatLines
    ];
  };
}
