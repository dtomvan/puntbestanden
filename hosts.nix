{
  amdpc1 = {
    hostName = "boomer";
    system = "x86_64-linux";
    hardware = {
      cpuVendor = "amd";
    };
    remoteBuild = {
      enable = true;
      settings = {
        maxJobs = 12;
        supportedFeatures = ["benchmark" "nixos-test" "big-parallel" "kvm"];
        speedFactor = 4;
      };
    };
    os = {
      isGraphical = true;
      wantsKde = true;
      extraModules = [
        ./os/hardware/boomer-disko.nix
        ./os/hardware/nvidia.nix
        ./os/hardware/ssd.nix
      ];
    };
  };

  tpx1g8 = {
    hostName = "feather";
    system = "x86_64-linux";
    hardware = {
      cpuVendor = "intel";
    };
    remoteBuild.enable = false;
    os = {
      isGraphical = true;
      wantsKde = true;
      extraModules = [
        ./os/hardware/comet-lake.nix
        ./os/hardware/elan-tp.nix
        ./os/hardware/fprint.nix
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
      extraModules = [];
    };
  };
}
