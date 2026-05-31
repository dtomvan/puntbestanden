{ inputs, ... }:
{
  perSystem =
    { pkgs, lib, ... }:
    let
      myCddaPackages = lib.recurseIntoAttrs (
        pkgs.callPackage "${inputs.nixpkgs-cdda.outPath}/pkgs/games/cataclysm-dda" { }
      );
      damalskSoundpack = myCddaPackages.pkgs.buildSoundPack {
        modName = "@'s Soundpack";
        version = "0-unstable-2019-06-07";
        src = pkgs.fetchFromGitHub {
          owner = "damalsk";
          repo = "damalsksoundpack";
          rev = "a69ed2bb65350b2700004b42fca02a5559fd8dad";
          hash = "sha256-/wEkfXy1Ov/sH3gyFUWFTQ2iH74+yI6+nzlQSa3a2eg=";
        };
      };
      myCdda =
        { hasTiles }:
        (myCddaPackages.dark-days-ahead.overrideAttrs (
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
        )).withMods
          (_: [ damalskSoundpack ]);
    in
    {
      packages = {
        myCdda = myCdda { hasTiles = true; };
        myCddaCurses = myCdda { hasTiles = false; };
      };
    };
}
