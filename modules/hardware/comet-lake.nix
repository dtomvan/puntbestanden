{
  flake.modules.nixos.hardware-comet-lake =
    { pkgs, ... }:
    {
      boot.initrd.kernelModules = [ "i915" ];
      boot.kernelParams = [ "i915.enable_guc=2" ];

      hardware.graphics = {
        enable = true;
        # TODO: remove when steam becomes 64-bit
        enable32Bit = true;
        extraPackages = builtins.attrValues {
          inherit (pkgs)
            intel-compute-runtime
            intel-media-driver
            vpl-gpu-rt
            ;
        };

        extraPackages32 = [
          pkgs.driversi686Linux.intel-media-driver
        ];
      };
    };
}
