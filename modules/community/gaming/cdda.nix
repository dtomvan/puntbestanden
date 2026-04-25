{ inputs, ... }:
{
  flake-file.inputs.nixpkgs-cdda.url = "github:RossSmyth/nixpkgs/cddaClean";

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
            version = "0.I-unstable-2026-04-15";
            src = pkgs.fetchFromGitHub {
              owner = "CleverRaven";
              repo = "Cataclysm-DDA";
              rev = "46730b6e7a9ed1c5eebf065a40760183d8d39fc2";
              hash = "sha256-4RjYr3GNIeIKiSLJ046fALoogDcQlq+ouroYmASwC80=";
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
