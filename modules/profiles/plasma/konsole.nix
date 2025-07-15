{
  flake.modules.homeManager.plasma =
    { pkgs, lib, ... }:
    {
      programs.konsole = {
        enable = true;
        customColorSchemes.catppuccin-mocha = ./catppuccin-mocha.colorscheme;
        defaultProfile = "Catppuccin";
        profiles.Catppuccin = {
          colorScheme = "catppuccin-mocha";
          command = "${lib.getExe pkgs.bashInteractive}";
        };
      };
    };
}
