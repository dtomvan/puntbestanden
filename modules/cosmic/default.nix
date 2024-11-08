{ config, lib, pkgs, ...}: let
	cfg = config.modules.cosmic;
	moossl = config.lib.file.mkOutOfStoreSymlink;
	readDir = import ../../lib/readdir.nix { inherit lib; };
in {
	options.modules.cosmic = {
		enable = lib.mkEnableOption "configure cosmic";
	};
	# config = lib.mkIf cfg.enable (let
	# configDir = ./config;
	# createFile = path: {
	# 	name = "cosmic/" + toString path;
	# 	value = { source = config.lib.file.mkOutOfStoreSymlink path; };
	# };
	# createFiles = paths: lib.lists.forEach paths createFile;
	# getFiles = paths: builtins.listToAttrs (createFiles paths);
	# cosmicFiles = map (p: configDir + "/${p}") (readDir.files configDir);
	# in {
	# 	xdg.configFile = getFiles cosmicFiles;
	# });
}
