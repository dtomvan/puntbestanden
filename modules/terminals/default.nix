{
  flake.modules.homeManager.terminals =
    {
      lib,
      ...
    }:
    {
      options.modules.terminals = {
        font.family = lib.mkOption {
          description = "the font to use in the terminal";
          default = "Aporetic Sans Mono";
          type = lib.types.str;
        };
        font.size = lib.mkOption {
          description = "the font size to use in the terminal";
          default = 12;
          type = lib.types.ints.between 9 30;
        };
      };
    };
}
