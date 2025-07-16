# This file reduces priority for IOnice, EEVDF and systemd-oomd for nix. This
# hopefully makes nix not:
# - kill my plasma session
# - make my PC extremely unresponsive to the point where I can't even `ls`
# - get my laptop extremely hot at times during a random GC
{
  flake.modules.nixos.nix-common = {
    nix = {
      daemonCPUSchedPolicy = "batch";
      daemonIOSchedClass = "idle";
      daemonIOSchedPriority = 7;
    };

    systemd.services = {
      nix-gc.serviceConfig = {
        CPUSchedulingPolicy = "batch";
        IOSchedulingClass = "idle";
        IOSchedulingPriority = 7;
      };

      # comment and option copied from nix-community/srvos
      #
      # Make builds to be more likely killed than important services.
      # 100 is the default for user slices and 500 is systemd-coredumpd@
      # We rather want a build to be killed than our precious user sessions as
      # builds can be easily restarted.
      nix-daemon.serviceConfig.OOMScoreAdjust = 250;
    };
  };
}
