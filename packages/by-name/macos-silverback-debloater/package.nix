{
  stdenv,
  lib,
  fetchFromGitHub,
  clj-ask,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "macos-silverback-debloater";
  version = "";

  src = fetchFromGitHub {
    owner = "Wamphyre";
    repo = "macOS_Silverback-Debloater";
    rev = "a5e8fea2fe5c36f2504d6d5705dd9433a6d0eb63";
    hash = "sha256-8xE/Tmr2vSXfy5oPfolaXF39SpUGvKMdL5YViMhZlEE=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm555 macOS_Silverback-Debloater.sh $out/bin/macos-silverback-debloater
    ${lib.concatStrings [
      ''sed -i $out/bin/macos-silverback-debloater''
      '' '2a\ if [[ 0 -eq `${clj-ask}/bin/ask.clj''
      '' "Are you sure you want to debloat your MacOS?"` ]];''
      ''then exit; fi' ''
    ]}

    runHook postInstall
  '';

  dontBuild = true;

  meta = {
    description = "Heavy MacOS debloater, use at own risk";
    homepage = "https://github.com/Wamphyre/macOS_Silverback-Debloater";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.darwin;
  };
})
