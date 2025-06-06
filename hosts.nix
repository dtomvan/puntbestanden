{
  amdpc1 = {
    hostName = "boomer";
    system = "x86_64-linux";
    hardware = {
      cpuVendor = "amd";
      gpuVendor = "nvidia";
    };
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
    os = {
      isGraphical = true;
      wantsKde = true;
      extraModules = [
        ./os/hardware/boomer-disko.nix
        ./os/hardware/ssd.nix
      ];
    };
  };

  tpx1g8 = {
    hostName = "feather";
    system = "x86_64-linux";
    hardware = {
      cpuVendor = "intel";
      gpuVendor = "intel";
    };
    remoteBuild.enable = true;
    os = {
      isGraphical = true;
      wantsKde = true;
      extraModules = [
        ./os/hardware/comet-lake.nix
        ./os/hardware/elan-tp.nix
        # ./os/hardware/fprint.nix
      ];
    };
  };

  hp3600 = {
    hostName = "kaput";
    system = "x86_64-linux";
    hardware = {
      cpuVendor = "intel";
    };
    remoteBuild.enable = false;
    os = {
      isGraphical = false;
      wantsKde = false;
      extraModules = [ ];
    };
  };

  x86-darwin-kvm = {
    hostName = "autisme";
    system = "x86_64-darwin";
    hardware = {
      cpuVendor = "intel";
    };
    remoteBuild = {
      enable = true;
      settings = {
        maxJobs = 6;
        speedFactor = 1;
      };
    };
  };
}
