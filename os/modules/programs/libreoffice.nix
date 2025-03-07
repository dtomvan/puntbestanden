{ pkgs, lib, config, ... }: {
	options.modules.programs.libreoffice.package = lib.mkPackageOption pkgs "libreoffice-qt6-fresh" {};
	config.environment.systemPackages = [ config.modules.programs.libreoffice.package ];
}
