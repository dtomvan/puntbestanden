{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.modules.terminals.ghostty;
in {
  options.modules.terminals.ghostty = with lib; {
    enable = mkEnableOption "install and configure ghostty";
    default = mkEnableOption "make ghostty the default terminal; only 1 can be the default";
    package = mkOption {
      description = "the ghostty package to use";
      default = pkgs.ghostty;
      type = types.package;
    };
    use-nix-colors = mkEnableOption "use nix-colors for colorscheme";
    font.family = mkOption {
      description = "the font to use in the ghostty terminal";
      default = "${config.modules.nerd-fonts.main-nerd-font} Nerd Font";
      type = types.str;
    };
    font.size = mkOption {
      description = "the font size to use in the ghostty terminal";
      default = 14;
      type = types.ints.between 9 30;
    };
  };
  config = lib.mkIf cfg.enable {
    modules.terminals = lib.mkIf cfg.default {
      name = lib.mkForce "ghostty";
      bin = lib.mkForce "${lib.getExe cfg.package}";
    };
    programs.ghostty = {
      enable = true;
      package = pkgs.symlinkJoin {
				name = "ghostty-nixgl";
				paths = [cfg.package];
				buildInputs = [pkgs.makeWrapper];
				postBuild = ''
				mv $out/bin/ghostty $out/bin/ghostty-unwrapped
				printf "#!%s\n\nnixGL %s %s" ${lib.getExe pkgs.bash} $out/bin/ghostty-unwrapped '$@' > $out/bin/ghostty
				chmod a+x $out/bin/ghostty
				'';
			};
    };
		# xdg.desktopEntries."com.mitchellh.ghostty" = {
		# 	name = "Ghostty";
		# 	exec = "nixGL ghostty";
		# 	icon = "com.mitchellh.ghostty";
		# 	terminal = false;
		# 	categories = ["System"];
		# 	actions.new-window = {
		# 		name = "New Window";
		# 		exec = "nixGL ghostty";
		# 	};
		# };
    xdg.configFile."ghostty/config".text = ''
      font-family = ${cfg.font.family}
      font-size = ${builtins.toString cfg.font.size}
      theme = ${
        if cfg.use-nix-colors
        then config.colorScheme.slug
        else "catppuccin-mocha"
      }
      gtk-single-instance = true
      command = zsh
    '';
  };
}
