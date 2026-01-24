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
      wirelessInterface = "wlp7s0";
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
      wirelessInterface = "wlp0s20f3";
      remoteBuild.enable = true;
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
