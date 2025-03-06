{lib, ...}: {
  nix.settings = {
    experimental-features = lib.mkDefault ["nix-command" "flakes"];
  };

  nix.channel.enable = false;
}
