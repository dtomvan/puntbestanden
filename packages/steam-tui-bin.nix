{
	stdenv,
	lib,
	fetchurl,
	autoPatchelfHook,
	openssl_3,
	libgcc,
	...
}: stdenv.mkDerivation rec {
	pname = "steam-tui";
	version = "0.3.0";
	src = fetchurl {
		url = "${meta.homepage}/releases/download/${version}/${pname}";
		sha256 = "sha256-o542qr0FKGEl84TPKG519KFfZjSEEXABPxGn4SWwJ2w=";
	};
	dontUnpack = true;
	nativeBuildInputs = [
		autoPatchelfHook
		openssl_3
		libgcc
	];

	installPhase = ''
    runHook preInstall
    install -m755 -D $src $out/bin/steam-tui
    runHook postInstall
	'';

	meta = {
	  description = "Just a simple TUI client for steamcmd. Allows for the graphical launching, updating, and downloading of steam games through a simple terminal client";
	  homepage = "https://github.com/dmadisetti/steam-tui/";
	  license = lib.licenses.mit;
	  # maintainers = with lib.maintainers; [  ];
	};
}
