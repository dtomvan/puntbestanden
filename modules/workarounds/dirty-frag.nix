{
  flake.modules.nixos.profiles-base =
    { pkgs, lib, ... }:
    let
      vulnerableModules = [
        "esp4"
        "esp6"
        "rxrpc"
      ];
    in
    {
      # disable loading kernel modules after we are fully initialized. This
      # does break apps like droidcam because it modprobes v4l2loopback JIT.
      security.lockKernelModules = true;

      # ...and also just get rid of these modules since we don't need it
      boot.extraModprobeConfig = lib.concatMapStringsSep "\n" (
        m: "install ${m} ${lib.getExe' "false" pkgs.coreutils}"
      ) vulnerableModules;
      boot.blacklistedKernelModules = vulnerableModules;
    };
}
