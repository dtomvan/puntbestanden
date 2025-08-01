{
  flake.modules.nixos.hardware-nvidia =
    { config, ... }:
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
        package = config.boot.kernelPackages.nvidiaPackages.production;
      };
      boot.extraModprobeConfig = ''
        options nvidia NVreg_PreserveVideoMemoryAllocations=1
      '';
    };
}
