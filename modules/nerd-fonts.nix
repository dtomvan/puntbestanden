{ config, pkgs, lib, ... }: let
	cfg = config.modules.nerd-fonts;
in {
    options.modules.nerd-fonts = {
        enable = lib.mkEnableOption "install nerd fonts";
        main-nerd-font = lib.mkOption {
            description = "Nerd font to install and use";
            default = "Iosevka";
            type = lib.types.str;
        };
        extra-nerd-fonts = lib.mkOption {
            description = "List of other nerd fonts you want available";
            default = [ ];
            type = with lib.types; listOf str;
        };
    };

    config = lib.mkIf cfg.enable {
        home.packages = [ (pkgs.nerdfonts.override { fonts = with cfg; extra-nerd-fonts ++ [ main-nerd-font ]; }) ];
    };
}
