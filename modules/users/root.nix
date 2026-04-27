{
  flake.modules.nixos.users-root =
    { pkgs, ... }:
    {
      users.users.root = {
        shell = pkgs.bashInteractive;
        initialHashedPassword = "$y$j9T$fTcxRBZwvzjTTvQNHDNDk/$CKiqCVJUBMl9UFMNjZXfIEHHPadkPHkciGctzKGu0HC";
      };
    };
}
