{ config, lib, pkgs, ... }: let
  cfg = config.modules.sowon;
in {
	options.modules.sowon = with lib; {
		enable = mkEnableOption "Install `sowon`";
		enablePenger = mkEnableOption "Enable -DPENGER";
	};
	config.home.packages = lib.optionals cfg.enable [
		(pkgs.sowon.override { inherit (cfg) enablePenger; })
	];
}
