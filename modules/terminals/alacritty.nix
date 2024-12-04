{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.terminals.alacritty;
in {
  options.modules.terminals.alacritty = with lib; {
    enable = mkEnableOption "install and configure alacritty";
    default = mkEnableOption "make alacritty the default terminal; only 1 can be the default";
    package = mkOption {
      description = "the alacritty package to use";
      default = pkgs.alacritty;
      type = types.package;
    };
    use-nix-colors = mkEnableOption "use nix-colors for colorscheme";
    font.family = mkOption {
      description = "the font to use in the alacritty terminal";
      default = "${config.modules.nerd-fonts.main-nerd-font} Nerd Font";
      type = types.str;
    };
    font.size = mkOption {
      description = "the font size to use in the alacritty terminal";
      default = 14;
      type = types.ints.between 9 30;
    };
  };
  config = lib.mkIf cfg.enable {
    modules.terminals = lib.mkIf cfg.default {
      name = lib.mkForce "alacritty";
      bin = lib.mkForce "${lib.getExe cfg.package}";
    };
    programs.alacritty = {
      enable = true;
      package = cfg.package;
      settings = {
        font.size = cfg.font.size;
        font.normal.family = cfg.font.family;
        # window.dynamic_title = true;
        # general.live_config_reload = true;
        colors = lib.mkIf cfg.use-nix-colors (with config.colorScheme.palette; {
          primary.background = "0x${base00}";
          primary.foreground = "0x${base05}";

          cursor.text = "0x${base00}";
          cursor.cursor = "0x${base05}";

          normal.black = "0x${base00}";
          normal.red = "0x${base08}";
          normal.green = "0x${base0B}";
          normal.yellow = "0x${base0A}";
          normal.blue = "0x${base0D}";
          normal.magenta = "0x${base0E}";
          normal.cyan = "0x${base0C}";
          normal.white = "0x${base05}";

          bright.black = "0x${base03}";
          bright.red = "0x${base09}";
          bright.green = "0x${base01}";
          bright.yellow = "0x${base02}";
          bright.blue = "0x${base04}";
          bright.magenta = "0x${base06}";
          bright.cyan = "0x${base0F}";
          bright.white = "0x${base07}";
        });
      };
    };
  };
}
