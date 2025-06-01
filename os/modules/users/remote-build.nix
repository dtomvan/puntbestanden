{ lib, host, ... }:
let
  isLinux = lib.hasInfix "linux" host.system;
in
{
  users.users.remotebuild = {
    ${if isLinux then "isNormalUser" else null} = true;
    createHome = false;
    ${if isLinux then "group" else null} = "remotebuild";

    openssh.authorizedKeys.keyFiles = [ ./remotebuild.pub ];
  };

  users.groups.remotebuild = lib.mkIf isLinux { };

  nix.settings.trusted-users = [ "remotebuild" ];
}
