{ pkgs, ... }:
{
  users.users.root = {
    shell = pkgs.bash;
    initialHashedPassword = "$y$j9T$fTcxRBZwvzjTTvQNHDNDk/$CKiqCVJUBMl9UFMNjZXfIEHHPadkPHkciGctzKGu0HC";
  };
}
