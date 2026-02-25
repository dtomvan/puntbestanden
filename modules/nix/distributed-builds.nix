{ config, ... }:
let
  inherit (config) hosts;
in
{
  flake.modules.nixos.nix-distributed-builds =
    { host, ... }:
    {
      nix.distributedBuilds = true;
      nix.settings.builders-use-substitutes = true;

      nix.buildMachines =
        map
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
            builtins.filter (h: h.remoteBuild.enable && h != host) # don't build for yourself
              (builtins.attrValues hosts)
          );
    };

  flake.modules.homeManager.profiles-base = {
    programs.bash.shellAliases = {
      noremotebuild = "export NIX_CONFIG='builders = '";
      nore = "noremotebuild";
      remotebuild = "unset NIX_CONFIG";
      re = "remotebuild";
    };
  };
}
