{
  perSystem =
    { pkgs, lib, ... }:
    {
      packages.myLutris = pkgs.symlinkJoin {
        inherit (pkgs.lutris) pname version;
        paths = [ pkgs.lutris ];

        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/lutris \
            --prefix PATH : "${lib.makeBinPath [ pkgs.wineWow64Packages.wayland ]}"
        '';
      };
    };
}
