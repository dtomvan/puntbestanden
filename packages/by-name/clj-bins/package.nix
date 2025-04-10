{
  stdenvNoCC,
  babashka,
}: stdenvNoCC.mkDerivation {
  pname = "clj-bins";
  version = "0.1.0";

  source = ./.;
  dontUnpack = true;

  buildInputs = [
    babashka
  ];

  installPhase = ''
  mkdir -p $out/bin
  cp ${./.}/*.clj $out/bin
  '';
}
