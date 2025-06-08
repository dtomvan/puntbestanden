{ inputs, config, ... }:
let
  host = "127.0.0.1";
  port = 42420;
in
{
  services.vintagestory = {
    enable = true;
    inherit host port;
    extraFlags = [
      "--addModPath"
      (builtins.toString (inputs.vs2nix.legacyPackages.x86_64-linux.makeModsDir "my-mods" (mods: with mods; [
        primitivesurvival
        carryon
        xskills
      ])))
    ];
  };

  services.rathole = {
    enable = true;
    role = "client";
    settings.client = {
      remote_addr = "vitune.app:2333";
      services.vintagestory.local_addr = "${host}:${builtins.toString port}";
    };
    credentialsFile = config.sops.secrets.rathole-client.path;
  };

  sops.secrets.rathole-client = {
    mode = "0444";
    format = "binary";
    sopsFile = ../../secrets/vitune/rathole-client.secret;
    restartUnits = [ "rathole.service" ];
  };
}
