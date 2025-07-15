{
  flake.modules.nixos.nix-common = {
    nix = {
      settings = {
        extra-substituters = [
          "https://nix-community.cachix.org"
          "https://cache.garnix.io"
        ];

        extra-trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        ];
      };
    };
  };
}
