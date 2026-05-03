{ config, lib, ... }:
# How to add a host
# 1. Create a file (usually in modules/hosts/) that sets
#    `flake.modules.nixos.hosts-foobar` and `hosts.foobar`
# 2. nixos-generate-config --show-hardware-config > modules/hardware/_generated/foobar.nix
# minimal hosts entry:
# {
#   hosts.foobar = {
#     hostName = "foobar";
#     system = "x86_64-linux";
#     users = [ ];
#     mainDisk = "/dev/disk/by-id/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";
#   };
# }
let
  inherit (lib)
    attrValues
    concatLines
    filter
    mkEnableOption
    mkOption
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
    sshPubkey = mkOption {
      description = "Public key that is recognized by other machines in authorized_keys";
      type = nullOr (submodule keyModule);
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
    hasConfig = (mkEnableOption "configuring this host for nixos") // {
      default = true;
    };
    hasDoc = (mkEnableOption "listing this hostname in readme.md with its description") // {
      default = true;
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
    perSystem.legacyPackages.hosts = builtins.toFile "hosts.json" (builtins.toJSON config.hosts);

    text.readme.parts.hostnames = ''
      ## The hostnames

    ''
    + (
      config.hosts
      |> attrValues
      |> filter (h: h.hasDoc)
      |> map (h: "- `${h.hostName}`, ${h.description}")
      |> concatLines
    );
  };
}
