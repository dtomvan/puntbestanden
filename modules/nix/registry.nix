{
  flake.modules.nixos.nix-common = {
    nixpkgs.flake.setFlakeRegistry = true;
    # loosey goosey dependency, it's fine though. always pull the latest
    # one please!
    nix.registry.templates = {
      from = {
        type = "indirect";
        id = "templates";
      };
      to = {
        type = "git";
        url = "https://git.toostveen.nl/tom/templates";
      };
    };
  };
}
