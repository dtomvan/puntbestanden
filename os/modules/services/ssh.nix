{
  config,
  lib,
  ...
}: let
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
    users.users.${cfg.mainUser}.openssh.authorizedKeys.keys =
      [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFkdbc1mWvIUciwrrIZVRYrZwTBmQ7Cehd/laxzzdlyL tomvd@boomer"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICYRKHdw4dNFdV36OmEQvxEvko5fpkfV/Ch6pQypmOo8 tomvd@feather"
      ]
      ++ cfg.extraKeys;
  };
}
