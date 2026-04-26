{
  flake.modules.nixos.nix-common.nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    channel.enable = false;
  };
}
