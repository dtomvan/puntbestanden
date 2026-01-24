{
  flake.modules.nixos.services-dispatcharr =
    { config, lib, ... }:
    let
      baseConfig = {
        image = "ghcr.io/dispatcharr/dispatcharr:latest";
        ports = [
          "9191:9191"
        ];
        environment = {
          DISPATCHARR_ENV = "aio";
          REDIS_HOST = "localhost";
          CELERY_BROKER_URL = "redis://localhost:6379/0";
          DISPATCHARR_LOG_LEVEL = "info";
          UWSGI_NICE_LEVEL = "-5";
        };
        volumes = [
          "dispatcharr_data:/data"
        ];
        capabilities = {
          SYS_NICE = true;
        };
      };

      isIntel = lib.any (p: lib.hasInfix "intel" p) config.hardware.graphics.extraPackages;
      isAmd = config.hardware.graphics.enable;
      isVaapi = isIntel || isAmd;

      intelConfig' = {
        devices = [
          "/dev/dri:/dev/dri"
        ];
      };

      intelConfig = if isVaapi then intelConfig' else { };

      isNvidia = config.hardware.nvidia.enabled;

      nvidiaConfig' = {
        extraOptions = [
          "--device=nvidia.com/gpu=all"
        ];
      };

      nvidiaConfig = if isNvidia then nvidiaConfig' else { };
    in
    {
      virtualisation.oci-containers.containers.dispatcharr = baseConfig // intelConfig // nvidiaConfig;

      hardware.nvidia-container-toolkit.enable = lib.mkIf isNvidia (lib.mkDefault true);
    };
}
