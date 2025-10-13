{
  perSystem =
    { pkgs, ... }:
    {
      packages.hostnamer = pkgs.callPackage (
        {
          stdenv,
          systemdLibs,
          pkg-config,
        }:
        stdenv.mkDerivation {
          pname = "hostnamer";
          version = "0.0.0";
          src = ./.;

          nativeBuildInputs = [ pkg-config ];
          buildInputs = [ systemdLibs ];

          installPhase = ''
            install -Dm755 hostnamer -t $out/bin
          '';
        }
      ) { };
    };
}
