{
  flake.modules.nixos.users-remote-build =
    args@{ lib, config, ... }:
    let
      isBuilder = args ? host;
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
