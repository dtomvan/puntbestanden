{
  flake.modules.nixos.hardware-nvidia =
    {
      config,
      lib,
      pkgs,
      host ? null,
      ...
    }:
    let
      # TASK(20260204-235918)
      isNvidiaPascal = host.isNvidiaPascal or false;
    in
    lib.mkMerge [
      {
        boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.graphics = {
          enable = true;
          enable32Bit = true;
        };
        hardware.nvidia = {
          modesetting.enable = true;
          powerManagement.enable = false;
          powerManagement.finegrained = false;
          open = false;
        };
        boot.extraModprobeConfig = ''
          options nvidia NVreg_PreserveVideoMemoryAllocations=1
        '';
      }
      (lib.mkIf isNvidiaPascal {
        # 6.18 is the last longterm that is supported by nvidia 580.
        boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_18;
        hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
          version = "580.119.02";
          sha256_64bit = "sha256-gCD139PuiK7no4mQ0MPSr+VHUemhcLqerdfqZwE47Nc=";
          sha256_aarch64 = "sha256-eYcYVD5XaNbp4kPue8fa/zUgrt2vHdjn6DQMYDl0uQs=";
          openSha256 = "sha256-l3IQDoopOt0n0+Ig+Ee3AOcFCGJXhbH1Q1nh1TEAHTE=";
          settingsSha256 = "sha256-sI/ly6gNaUw0QZFWWkMbrkSstzf0hvcdSaogTUoTecI=";
          persistencedSha256 = "sha256-j74m3tAYON/q8WLU9Xioo3CkOSXfo1CwGmDx/ot0uUo=";
        };
      })
    ];
}
