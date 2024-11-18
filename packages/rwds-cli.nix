{
  stdenv,
  fetchzip,
  autoPatchelfHook,
  lib,
  libgcc,
}: let
  version = "0.1.0";
in
  stdenv.mkDerivation {
    inherit version;
    pname = "rwds-cli";

    src = fetchzip {
      url = "https://github.com/dtomvan/rusty-words/releases/download/v${version}/rwds-cli-bin-linux-x86_64.tar.gz";
      hash = "sha256-OA1YdCWPYhHxA72ZpfwRvslrM9V/zwODVgVmRAGqFEM=";
    };

    nativeBuildInputs = [
      autoPatchelfHook
	  libgcc
    ];

	dontConfigure = true;
	dontBuild = true;

    sourceRoot = ".";

    installPhase = ''
      runHook preInstall
      install -m755 -D source/rwds-cli $out/bin/rwds-cli
	  patchelf \
		  --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
		  $out/bin/rwds-cli
      runHook postInstall
    '';

    meta = with lib; {
      homepage = "https://github.com/dtomvan/rusty-words/";
      description = "Program to study flashcards";
      platforms = platforms.linux;
    };
  }
