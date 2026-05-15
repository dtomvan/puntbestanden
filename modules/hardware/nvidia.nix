{
  flake.modules.nixos.hardware-nvidia =
    {
      config,
      lib,
      inputs',
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
        boot.kernelPackages = lib.mkForce inputs'.nixos-small.legacyPackages.linuxPackages_6_18;
        # LTS until Aug 2028, let's hope I have a new graphics card by then
        hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
      })
    ];
}
