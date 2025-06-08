{ config, ... }:
{
  # TODO: when services.vintagestory gets merged, set that up. this is just the
  # reverse proxy for now.
  services.rathole = {
    enable = true;
    role = "client";
    settings.client = {
      remote_addr = "vitune.app:2333";
      services.vintagestory.local_addr = "127.0.0.1:42420";
    };
    credentialsFile = config.sops.secrets.rathole-credentials.path;
  };

  sops.secrets.rathole-credentials = {
    mode = "0400";
    sopsFile = ../../secrets/vitune/rathole-credentials.secret;
    format = "binary";
    owner = "root";
    group = "wheel";
  };
}
