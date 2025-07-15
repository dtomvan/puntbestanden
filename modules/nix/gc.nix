{
  flake.modules.nixos.nix-common = {
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 14d";
      };

      optimise = {
        automatic = true;
      };
    };
  };
}
