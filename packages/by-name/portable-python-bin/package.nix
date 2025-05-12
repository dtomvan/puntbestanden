{
  lib,
  stdenv,
  fetchzip,
  freetype,
  autoPatchelfHook,
}:
let
  version = "3.9.22";
  buildNumber = "build.0";
  majorMinor = lib.concatStrings (lib.take 2 (lib.splitVersion version));

  suffix =
    rec {
      aarch64-linux = "linux-aarch64";
      x86_64-linux = "linux-x86_64";
      aarch64-darwin = "darwin-universal2";
      x86_64-darwin = aarch64-darwin;
    }
    ."${stdenv.hostPlatform.system}";
in
stdenv.mkDerivation {
  pname = "portable-python${majorMinor}-bin";
  version = "${version}-${buildNumber}";

  src = fetchzip {
    url = "https://github.com/bjia56/portable-python/releases/download/cpython-v${version}-${buildNumber}/python-full-${version}-${suffix}.zip";
    hash =
      rec {
        aarch64-linux = "sha256-7qw0+dKRmLvTC5p7GTJgjBrLsJsu6hvZp5zIIXAes9A=";
        x86_64-linux = "sha256-hPItLZ5JwWV0Lldf1nUT7KqTMmMQ2eH7LqZSXyEpHc8=";
        aarch64-darwin = "sha256-DyNDa68uWnOlqzo0JXuR6/SW9xN+8BSr15p2TLM/deo=";
        x86_64-darwin = aarch64-darwin;
      }
      ."${stdenv.hostPlatform.system}";
  };

  buildInputs = [ freetype ];
  nativeBuildInputs = [ autoPatchelfHook ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r * $out

    runHook postInstall
  '';

  meta = {
    description = "Portable Python binaries";
    homepage = "https://github.com/bjia56/portable-python";
    license = lib.licenses.asl20;
    mainProgram = "python3";
    platforms = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];
  };
}
