{ self, lib, ... }:
# How to add a host
# 1. Add an entry to this file
# 2. Create a file (usually in modules/hosts/) that sets modules.nixos.`hosts-foobar`
# 3. nixos-generate-config --show-hardware-config > modules/hardware/_generated/foobar.nix
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
  + lib.pipe self.hosts [
    lib.attrValues
    (lib.filter (h: !(h ? noDoc)))
    (lib.map (h: "- `${h.hostName}`, ${h.description}"))
    lib.concatLines
  ];
}
