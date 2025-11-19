# some banger FOSS games that can be installed even on `allowUnfree = false;`. Mostly roguelikes.
# closure size of all 3 together (except iWantToCompileCDDACurses): 7.2 GiB (as of 2025-11-19)
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
      cfg = config.programs.gaming-free;
    in
    {
      options.programs.gaming-free = {
        enable = mkEnableOption "some great FOSS games";
        enableGraphical = mkEnableOption "some great FOSS games that require a graphical session";
        enableBig = mkEnableOption "some great FOSS graphical games that have a big footprint (closure >1.5GiB)";
        # this option is useless because I'll probably only refer to the
        # package in question once in my dotfiles anyways
        iWantToCompileCDDACurses = mkEnableOption "CDDA but without the tiles so a bit smaller than normal";
      };
      config.environment.systemPackages =
        lib.optionals cfg.enable (
          with pkgs;
          [
            angband
            nethack
            rogue
          ]
        )
        ++ lib.optionals cfg.enableGraphical (
          with pkgs;
          [
            brogue-ce
            cataclysm-dda
            mindustry
            tome4
          ]
        )
        ++ lib.optionals cfg.enableBig (
          with pkgs;
          [
            xonotic
            zeroad
          ]
        )
        ++ lib.optionals cfg.iWantToCompileCDDACurses (
          with pkgs;
          [
            cataclysmDDA.stable.curses
          ]
        );
    };
}
