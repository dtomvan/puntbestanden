{
  flake.modules.nixos.users-remote-build =
    { lib, config, ... }:
    let
      isLinux = lib.hasInfix "linux" config.nixpkgs.hostPlatform.system;
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
    };
}
