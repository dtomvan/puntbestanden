{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  pkg-config,
  enablePenger ? true,
}:
stdenv.mkDerivation {
  pname = "sowon";
  version = "1.0";

  nativeBuildInputs = [
    SDL2
    pkg-config
  ];

  buildPhase = "make" + lib.optionalString enablePenger "CFLAGS=-DPENGER";

  installPhase = ''
    mkdir $out
    make PREFIX=$out install
  '';

  src = fetchFromGitHub {
    owner = "tsoding";
    repo = "sowon";
    rev = "558f125a78e8ede33e86c4ec584f87892a8ab94a";
    hash = "sha256-QloqwVkjZwsDtxZTaywVgKuKJsyBNpcKPjKHvw9Vql8=";
  };

  meta = {
    description = "Starting Soon Timer for Tsoding Streams";
    homepage = "https://github.com/tsoding/sowon";
    license = lib.licenses.mit;
    mainProgram = "sowon";
    platforms = lib.platforms.all;
  };
}
