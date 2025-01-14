{
  lib,
  stdenv,
  fetchzip,
}:
stdenv.mkDerivation rec {
  pname = "afio";
  version = "0.0.4";

  sourceRoot = ".";

  installPhase = ''
          runHook preInstall

          dst_truetype=$out/share/fonts/truetype/afio/

          find -name \*.ttf -exec mkdir -p $dst_truetype \; -exec cp -p {} $dst_truetype \;

          runHook postInstall
        '';

  src = fetchzip {
    url = "${meta.homepage}/releases/download/v${version}/afio-v${version}.zip";
    hash = "sha256-7L9pypexyyru6uUCPry4eUkAf7r3d6GooPjVYMCx20I=";
	stripRoot = false;
  };

  meta = {
    description = "Custom slimmed down Iosevka font with nerd-font icons";
    homepage = "https://github.com/awnion/custom-iosevka-nerd-font";
	platform = lib.platforms.all;
  };
}
