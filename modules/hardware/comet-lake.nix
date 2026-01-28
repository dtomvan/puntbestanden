{
  flake.modules.nixos.hardware-comet-lake =
    { pkgs, ... }:
    {
      boot.initrd.kernelModules = [ "i915" ];
      boot.kernelParams = [ "i915.enable_guc=2" ];

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
        extraPackages = with pkgs; [
          intel-compute-runtime
          intel-media-driver
          vpl-gpu-rt
        ];

        extraPackages32 = with pkgs; [
          driversi686Linux.intel-media-driver
        ];
      };
    };
}
