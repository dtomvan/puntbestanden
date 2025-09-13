{ self, ... }:
let
  inherit (self) hosts;
in
{
  flake.modules.nixos.users-remote-build =
    { lib, config, ... }:
    let
      isBuilder = lib.filterAttrs (_n: h: h.hostName == config.networking.hostName) hosts != { };
      isLinux = lib.hasInfix "linux" config.nixpkgs.hostPlatform.system;
    in
    {
      config = lib.mkIf isBuilder {
        users.users.remotebuild = {
          ${if isLinux then "isNormalUser" else null} = true;
          createHome = false;
          ${if isLinux then "group" else null} = "remotebuild";

          openssh.authorizedKeys.keyFiles = [ ./remotebuild.pub ];
        };

        users.groups.remotebuild = lib.mkIf isLinux { };

        nix.settings.trusted-users = [ "remotebuild" ];
      };
    };
}
