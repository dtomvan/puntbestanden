{
  lib,
  ...
}:
{
  imports = [
    ./alacritty.nix
    ./foot.nix
    ./ghostty.nix
  ];

  options.modules.terminals = with lib; {
    font.family = mkOption {
      description = "the font to use in the terminal";
      default = "afio";
      type = types.str;
    };
    font.size = mkOption {
      description = "the font size to use in the terminal";
      default = 12;
      type = types.ints.between 9 30;
    };
  };
}
