{ config, lib, ... }:
{
  flake.hosts = {
    amdpc1 = {
      description = "a reasonably sluggish Ryzen 5 2600 desktop PC";
      hostName = "boomer";
      system = "x86_64-linux";
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
      remoteBuild.enable = true;
    };

    hp3600 = {
      description = "a thick bastard of a laptop with a broken screen";
      hostName = "kaput";
      system = "x86_64-linux";
      remoteBuild.enable = false;
      noConfig = true;
    };

    bart-pc = {
      hostName = "vitune.app";
      system = "x86_64-linux";
      noConfig = true;
      noDoc = true;
      remoteBuild = {
        enable = true;
        settings = {
          sshUser = "nix-remote-builder";
          maxJobs = 2;
          supportedFeatures = [
            "benchmark"
            "big-parallel"
          ];
          speedFactor = 2;
        };
      };
    };
  };

  text.readme.parts.hostnames = ''
    ## The hostnames

  ''
  + lib.pipe config.flake.hosts [
    lib.attrValues
    (lib.filter (h: !(h ? noDoc)))
    (lib.map (h: "- `${h.hostName}`, ${h.description}"))
    lib.concatLines
  ];
}
