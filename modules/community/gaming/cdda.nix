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
}
