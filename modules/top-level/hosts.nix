{ config, lib, ... }:
# How to add a host
# 1. Add an entry to this file
# 2. Create a file (usually in modules/hosts/) that sets modules.nixos.`hosts-foobar`
# 3. nixos-generate-config --show-hardware-config > modules/hardware/_generated/foobar.nix
{
  # TASK(20260225-231620): make the hosts set less loose and more structured by
  # defining each available option
  options.hosts = lib.mkOption {
    description = "an inventory of all systems configured using this flake";
    type = with lib.types; attrsOf raw;
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
    + lib.pipe config.hosts [
      lib.attrValues
      (lib.filter (h: !(h ? noDoc)))
      (lib.map (h: "- `${h.hostName}`, ${h.description}"))
      lib.concatLines
    ];
  };
}
