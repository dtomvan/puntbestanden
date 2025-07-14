{
  flake.hosts = {
    amdpc1 = {
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
      hostName = "feather";
      system = "x86_64-linux";
      remoteBuild.enable = true;
    };

    hp3600 = {
      hostName = "kaput";
      system = "x86_64-linux";
      remoteBuild.enable = false;
    };
  };
}
