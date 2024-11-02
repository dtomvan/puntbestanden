{ lib, config, pkgs, ... }:
{
	options.modules.gtk = with lib; {
		enable = mkEnableOption "Install and configure a GTK2/3/4 theme";
	};
	config.gtk = lib.mkIf config.modules.gtk.enable (let
		extraConfig = {
			color-scheme = "prefer-dark";
		};
	in with pkgs; {
		enable = true;
		iconTheme = {
			name = "Adwaita";
			package = adwaita-icon-theme;
		};
		theme = {
			name = "Adwaita";
			package = gnome-themes-extra;
		};
		# is this needed?
		gtk3 = { extraConfig.gtk-theme-name = "Adwaita-dark"; };
		gtk4 = { inherit extraConfig; };
	});
}
