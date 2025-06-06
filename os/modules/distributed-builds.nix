{ host, ... }:
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
        builtins.filter (h: h.remoteBuild.enable && h.hostName != host.hostName) # don't build for yourself
          (builtins.attrValues (import ../../hosts.nix))
      );
}
