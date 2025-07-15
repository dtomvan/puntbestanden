{
  flake.modules.nixos.nix-common = {
    nix = {
      optimise = {
        automatic = true;
      };
    };
  };
}
