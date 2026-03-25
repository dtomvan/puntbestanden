# some banger FOSS games that can be installed even on `allowUnfree = false;`. Mostly roguelikes.
# closure size of all 3 together (except iWantToCompileCDDACurses): 7.2 GiB (as of 2025-11-19)
# without the biggies: 2.4 GiB
# just the non-graphical: 86.2 MiB
{ inputs, ... }:
{
  flake-file.inputs.nixpkgs-cdda.url = "github:RossSmyth/nixpkgs/cddaClean";

  perSystem =
    { pkgs, lib, ... }:
    let
      myCddaPackages = lib.recurseIntoAttrs (
        pkgs.callPackage "${inputs.nixpkgs-cdda.outPath}/pkgs/games/cataclysm-dda" { }
      );
      myCdda =
        { hasTiles }:
        myCddaPackages.dark-days-ahead.overrideAttrs (
          final: prev: {
            pname = if hasTiles then "${prev.pname}-tiles" else prev.pname;
            version = "0.I-2026-03-23-0402";
            src = pkgs.fetchFromGitHub {
              owner = "CleverRaven";
              repo = "Cataclysm-DDA";
              tag = "cdda-${final.version}";
              hash = "sha256-sfoZ8ey/hr0NGTJr/ywr/0/S6UcsSHkJoRfPaq7tfMc=";
            };
            patches = [ ./cdda-locale-path.patch ];
            inherit hasTiles;
          }
        );
    in
    {
      packages = {
        myCdda = myCdda { hasTiles = true; };
        myCddaCurses = myCdda { hasTiles = false; };
      };
    };

  flake.modules.nixos.gaming-free =
    {
      self',
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
        # xonotic
        zeroad
        ;
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
        lib.optionals cfg.enable [
          angband
          nethack
          rogue
        ]
        ++ lib.optionals cfg.enableGraphical [
          brogue-ce
          self'.packages.myCdda
          mindustry
          tome4
        ]
        ++ lib.optionals cfg.enableBig [
          # xonotic
          zeroad
        ]
        ++ lib.optionals cfg.iWantToCompileCDDACurses (lib.singleton self'.packages.myCddaCurses);
    };
}
