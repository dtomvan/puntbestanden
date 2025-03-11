{
  lib,
  name,
  package,
	defaultFontSize ? 12,
}:
with lib; {
  enable = mkEnableOption "install and configure ${name}";
  package = mkOption {
    description = "the ${name} package to use";
    default = package;
    type = types.package;
  };
  use-nix-colors = mkEnableOption "use nix-colors for colorscheme in ${name}";
  font.family = mkOption {
    description = "the font to use in the ${name} terminal";
    default = "JetBrainsMono Nerd Font";
    type = types.str;
  };
  font.size = mkOption {
    description = "the font size to use in the ${name} terminal";
    default = defaultFontSize;
    type = types.ints.between 9 30;
  };
}
