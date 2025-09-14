let
  schemeName = "catppuccin-mocha";
in
{
  flake.modules.homeManager.profiles-plasma =
    { pkgs, lib, ... }:
    {
      programs.konsole = {
        enable = true;
        customColorSchemes.${schemeName} = ./${schemeName}.colorscheme;
        defaultProfile = schemeName;
        profiles.${schemeName} = {
          colorScheme = schemeName;
          command = "${lib.getExe pkgs.bashInteractive}";
        };
      };
    };
}
