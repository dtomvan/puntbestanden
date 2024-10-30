{ config, pkgs, lib, ... }: {
    options = {
        nerd-fonts.enable = lib.mkEnableOption "install nerd fonts";
        nerd-fonts.main-nerd-font = lib.mkOption {
            description = "Nerd font to install and use";
            default = "Iosevka";
            type = lib.types.str;
        };
        nerd-fonts.extra-nerd-fonts = lib.mkOption {
            description = "List of other nerd fonts you want available";
            default = [ ];
            type = with lib.types; listOf str;
        };
    };

    config = lib.mkIf config.nerd-fonts.enable {
        home.packages = [ (pkgs.nerdfonts.override { fonts = with config.nerd-fonts; extra-nerd-fonts ++ [ main-nerd-font ]; }) ];
    };
}
