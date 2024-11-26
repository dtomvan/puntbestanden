{
  stdenv,
  fetchurl,
  lib,
}: let
  version = "1.9";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "doom1-wad-shareware";

    src = fetchurl {
      url = "https://distro.ibiblio.org/slitaz/sources/packages/d/doom1.wad";
      hash = "sha256-HX1DvlAeZ9kn5BXguPPinDvzMHXoWXIYFvZSpSbKx3E=";
    };

    dontUnpack = true;
    dontConfigure = true;
    dontBuild = true;

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -m755 -D $src $out/share/games/doom1.wad
      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://doomwiki.org/wiki/DOOM1.WAD";
      description = "Original doom shareware WAD.";
      platforms = platforms.all;
    };
  }
