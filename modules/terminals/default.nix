{
  config,
  lib,
  ...
}: let
  cfg = config.modules.terminals;
in {
  imports = [
    ./alacritty.nix
    ./foot.nix
    ./ghostty.nix
  ];
  options.modules.terminals = with lib; {
    enable = mkEnableOption "install a default terminal";
    name = mkOption {
      description = "name of the default terminal to use";
      default = "foot";
      type = types.str;
    };
    bin = mkOption {
      description = "the path in nix store to launch the terminal";
      default = "${cfg.foot.package}/bin/${cfg.name}";
      type = types.str;
    };
  };
  config.modules.terminals = lib.mkIf cfg.enable {
    foot.enable = lib.mkDefault true;

    alacritty.use-nix-colors = lib.mkDefault true;
    foot.use-nix-colors = lib.mkDefault true;
  };
}
