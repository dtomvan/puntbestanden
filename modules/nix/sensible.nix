{
  flake.modules.nixos.nix-common = {
    nix = {
      settings = {
        connect-timeout = 5;
        min-free = 128 * 1000 * 1000;
        max-free = 1 * 1000 * 1000 * 1000;
        fallback = true;

        # TODO: consider these
        # keep-outputs = true;
        # keep-going = true;
        # keep-failed = true;
      };
    };
  };
}
