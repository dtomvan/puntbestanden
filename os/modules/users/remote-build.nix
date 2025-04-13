{
  users.users.remotebuild = {
    isNormalUser = true;
    createHome = false;
    group = "remotebuild";

    openssh.authorizedKeys.keyFiles = [./remotebuild.pub];
  };

  users.groups.remotebuild = {};

  nix.settings.trusted-users = ["remotebuild"];
}
