{
  stdenv,
  makeWrapper,
  jdk,
  ...
}:
stdenv.mkDerivation {
  pname = "coach-cached";
  version = "1.0";
  src = ./dist/coach;
  buildInputs = [
    makeWrapper
  ];
  installPhase = ''
    mkdir $out
    cp -r * $out
    wrapProgram $out/bin/coach \
    --set "JAVA_HOME" "${jdk}"

    wrapProgram $out/bin/coach-lsp \
    --set "JAVA_HOME" "${jdk}"
  '';
}
