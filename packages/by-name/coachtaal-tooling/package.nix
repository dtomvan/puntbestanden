{
  coachtaal-tooling,
  lib,
  stdenv,
  fetchFromGitHub,
  jdk,
  kotlin,
  gradle,
  versionCheckHook,
  makeWrapper,
}:
stdenv.mkDerivation rec {
  pname = "coachtaal-tooling";
  version = "0-unstable-2025-02-21";

  src = fetchFromGitHub {
    owner = "770grappenmaker";
    repo = "coachtaal-tooling";
    rev = "c496e579fc45c77d98c1bd021807f20999ebea5e";
    hash = "sha256-HT2x2PcFG5mlWWutcarDQ9aEz4f4EXoHVJatbDygBeA=";
  };

  patches = [
    # can you tell I'm done with Gradle forever? no?
    ./no-impure-gradle-stuff-please-for-the-love-of-god.patch
  ];

  mitmCache = gradle.fetchDeps {
    # this ain't nixpkgs and inherit pname; doesn't work
    pkg = coachtaal-tooling;
    data = ./deps.json;
  };

  nativeBuildInputs = [
    gradle
    kotlin
    jdk
    makeWrapper
  ];

  gradleBuildTask = [
    ":app:installDist"
    ":lsp:build"
  ];

  installPhase = ''
    mkdir -p $out

    cp -rv app/build/install/coach/* $out
    rm $out/bin/coach.bat

    cp -rv lsp/extension/build/lsp.jar $out/lib
    makeWrapper ${jdk}/bin/java $out/bin/coach-lsp \
      --add-flags "-jar $out/lib/lsp.jar"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "CMA Coach 7 tools";
    homepage = "https://github.com/770grappenmaker/coachtaal-tooling";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "coach";
    platforms = lib.platforms.all;
  };
}
