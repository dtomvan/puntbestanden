{ config, ... }:
let
  inherit (config.flake) hosts;
in
{
  flake.modules.nixos.nix-distributed-builds =
    { config, ... }:
    {
      nix.distributedBuilds = true;
      nix.settings.builders-use-substitutes = true;

      nix.buildMachines =
        builtins.map
          (
            h:
            {
              inherit (h) system hostName;
              sshUser = "remotebuild";
              sshKey = "/root/.ssh/remotebuild";
            }
            // (h.remoteBuild.settings or { })
          )
          (
            builtins.filter (h: h.remoteBuild.enable && h.hostName != config.networking.hostName) # don't build for yourself
              (builtins.attrValues hosts)
          );
    };

  flake.modules.homeManager.profiles-base = {
    programs.bash.shellAliases = {
      noremotebuild = "export NIX_CONFIG='builders = \"\"'";
      nore = "noremotebuild";
      remotebuild = "unset NIX_CONFIG";
      re = "remotebuild";
    };
  };
}
