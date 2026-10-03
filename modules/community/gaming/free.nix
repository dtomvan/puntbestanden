# some banger FOSS games that can be installed even on `allowUnfree = false;`. Mostly roguelikes.
# closure size of all 3 together: 7.2 GiB (as of 2025-11-19)
# without the biggies: 2.4 GiB
# just the non-graphical: 86.2 MiB
{
  flake.modules.nixos.gaming-free =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) mkEnableOption;
      inherit (pkgs)
        angband
        brogue-ce
        mindustry
        nethack
        rogue
        tome4
        ;
      cfg = config.programs.gaming-free;
    in
    {
      options.programs.gaming-free = {
        enable = mkEnableOption "some great FOSS games";
        enableGraphical = mkEnableOption "some great FOSS games that require a graphical session";
      };
      config.environment.systemPackages =
        lib.optionals cfg.enable [
          angband
          nethack
          rogue
        ]
        ++ lib.optionals cfg.enableGraphical [
          brogue-ce
          mindustry
          tome4
        ];
    };
}
