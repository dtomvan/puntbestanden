{ lib, host, ... }:
let
  inherit (import ../../../lib/host.nix { inherit lib; }) isLinux;
  isLinux' = isLinux host;
in
{
  users.users.remotebuild = {
    ${if isLinux' then "isNormalUser" else null} = true;
    createHome = false;
    ${if isLinux' then "group" else null} = "remotebuild";

    openssh.authorizedKeys.keyFiles = [ ./remotebuild.pub ];
  };

  users.groups.remotebuild = lib.mkIf isLinux' { };

  nix.settings.trusted-users = [ "remotebuild" ];
}
