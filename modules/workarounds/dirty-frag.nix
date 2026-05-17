{
  flake.modules.nixos = {
    profiles-base =
      { pkgs, lib, ... }:
      let
        vulnerableModules = [
          "esp4"
          "esp6"
          "rxrpc"
        ];
      in
      {
        # TASK(20260517-203141): explicitly list extra modules per host that I need to load. How to do that????
        # disable loading kernel modules after we are fully initialized. This
        # does break apps like droidcam because it modprobes v4l2loopback JIT.
        security.lockKernelModules = lib.mkDefault true;

        # ...and also just get rid of these modules since we don't need it
        boot.extraModprobeConfig = lib.concatMapStringsSep "\n" (
          m: "install ${m} ${lib.getExe' pkgs.coreutils "false"}"
        ) vulnerableModules;
        boot.blacklistedKernelModules = vulnerableModules;
      };
    hosts-feather.security.lockKernelModules = false;
  };
}
