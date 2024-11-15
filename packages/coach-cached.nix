{
  stdenv,
  pkgs,
  ...
}:
stdenv.mkDerivation {
  pname = "coach-cached";
  version = "1.0";
  src = ./dist/coach;
  buildInputs = with pkgs; [
    makeWrapper
  ];
  installPhase = ''
    mkdir $out
    cp -r * $out
    wrapProgram $out/bin/coach \
    --set "JAVA_HOME" "${pkgs.jdk}"

    wrapProgram $out/bin/coach-lsp \
    --set "JAVA_HOME" "${pkgs.jdk}"
  '';
}
