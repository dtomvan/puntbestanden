{
  flake.modules.nixos.boot-quiet =
    {
      lib,
      config,
      ...
    }:
    {
      options.modules.boot.quiet = lib.mkEnableOption "quiet boot";
      config = lib.mkIf config.modules.boot.quiet {
        boot = {
          consoleLogLevel = 0;
          initrd.verbose = false;
          kernelParams = [
            "quiet"
            "splash"
            "boot.shell_on_fail"
            "loglevel=3"
            "rd.systemd.show_status=false"
            "rd.udev.log_level=3"
            "udev.log_priority=3"
          ];
          loader.timeout = lib.mkDefault 0;
        };
      };
    };
}
