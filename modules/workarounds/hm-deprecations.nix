{
  # The default value of `xdg.userDirs.setSessionVariables` has changed from `true` to `false`.
  # You are currently using the legacy default (`true`) because `home.stateVersion` is less than "26.05".
  flake.modules.homeManager.profiles-base.xdg.userDirs.setSessionVariables = true;
}
