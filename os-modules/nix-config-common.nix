{lib, ...}: {
  nixpkgs.config.allowUnfree = lib.mkDefault true;
  nix.settings = {
    experimental-features = lib.mkDefault ["nix-command" "flakes"];
  };
}
