{
  flake.modules.nixos.nix-common =
    { lib, ... }:
    {
      nix = {
        settings = {
          experimental-features = lib.mkDefault [
            "nix-command"
            "flakes"
          ];
        };
        channel.enable = false;
      };
    };
}
