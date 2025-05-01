{
  stdenv,
  lib,
  fetchzip,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "rwds-cli-bin";
  version = "0.1.0";

  src = fetchzip {
    url = "https://github.com/dtomvan/rusty-words/releases/download/v${finalAttrs.version}/rwds-cli-bin-nix-x86_64.tar.gz";
    hash = "sha256-p+qkHTGfIb8rw604Qrlic03eJXDJA6x3FK/KiTgfnnA=";
  };

  dontConfigure = true;
  dontBuild = true;

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -m755 -D source/rwds-cli $out/bin/rwds-cli

    runHook postInstall
  '';

  meta = {
    description = "Program to study flashcards";
    homepage = "https://github.com/dtomvan/rusty-words/";
    maintainers = with lib.maintainers; [ dtomvan ];
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
})
