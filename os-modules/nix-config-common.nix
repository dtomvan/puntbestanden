{lib, ...}: {
  nix.settings = {
    experimental-features = lib.mkDefault ["nix-command" "flakes"];
  };
}
