{
  nix.distributedBuilds = true;
  nix.settings.builders-use-substitutes = true;

  nix.buildMachines = builtins.map (
    host: {
      inherit (host) system hostName;
      sshUser = "remotebuild";
      sshKey = "/root/.ssh/remotebuild";
    } // host.remoteBuild.settings
  ) (builtins.filter (host: host.remoteBuild.enable) (builtins.attrValues (import ../../hosts.nix)));
}
