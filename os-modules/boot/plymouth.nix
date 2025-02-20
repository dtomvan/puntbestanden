{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.modules.boot.plymouth;
in {
  options.modules.boot.plymouth = with lib; {
    enable = mkEnableOption "boot with plymouth";
    themeName = mkOption {
      default = "nixos-bgrt";
      description = "plymouth theme name";
      type = types.str;
    };
    themePackage = mkPackageOption pkgs "nixos-bgrt-plymouth" {};
  };

	imports = [ ./quiet.nix ];
  config = lib.mkIf cfg.enable {
		modules.boot.quiet = lib.mkDefault true;
    boot.plymouth = {
      enable = true;
      theme = cfg.themeName;
      themePackages = [cfg.themePackage];
    };
  };
}
