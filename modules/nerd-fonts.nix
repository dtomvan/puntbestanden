{
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}: let
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
      default = [];
      type = with lib.types; listOf str;
    };
  };

  config = lib.mkIf cfg.enable (let
	font-metadata = lib.importJSON ./fonts.json;
    find-font = font: lib.findFirst (pkg: font == pkg.patchedName) null font-metadata;
	get-font = font: lib.getAttr (find-font font).caskName pkgs.nerd-fonts;
  in {
    home.packages = lib.map get-font ([cfg.main-nerd-font] ++ cfg.extra-nerd-fonts);
  });
}
