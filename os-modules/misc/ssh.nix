{config, lib, pkgs, ...}: let
cfg = config.modules.ssh;
in {
	options.modules.ssh = with lib; {
		enable = mkEnableOption "ssh";
		mainUser = mkOption {
			default = "tomvd";
			type = types.str;
		};
		extraKeys = mkOption {
			default = [];
			type = with types; listOf str;
		};
	};
	config = lib.mkIf cfg.enable {
		services.openssh.enable = true;
		users.users.${cfg.mainUser}.openssh.authorizedKeys.keys = [
			"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkdbc1mWvIUciwrrIZVRYrZwTBmQ7Cehd/laxzzdlyL 18gatenmaker6@gmail.com"
		] ++ cfg.extraKeys;
	};
}
