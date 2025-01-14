{ pkgs, lib, config, ... }: {home.file = {
	cheats = { recursive = true; source = config.lib.file.mkOutOfStoreSymlink ../stow/cheats; };
};}
