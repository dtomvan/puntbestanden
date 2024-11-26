{ config, lib, pkgs, ... }: let
  cfg = config.modules.minecraft;
in {
	options.modules.minecraft = with lib; {
		enable = mkEnableOption "Download and install prismlauncher";
	};
	config = lib.mkIf cfg.enable {
		home.packages = [
		(
			pkgs.prismlauncher.override {
				jdks = with pkgs; [ jdk8 zulu23 ];
				additionalPrograms = [ pkgs.mangohud ];
				controllerSupport = false;
				gamemodeSupport = true;
				textToSpeechSupport = false;
			}
		)
		];
	};
}
