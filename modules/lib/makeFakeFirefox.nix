{
  perSystem =
    { pkgs, lib, ... }:
    {
      legacyPackages.makeFakeFirefox =
        firefox:
        lib.makeOverridable (
          { args, ... }:
          pkgs.stdenvNoCC.mkDerivation {
            inherit (firefox) pname version;
            src = firefox;

            nativeBuildInputs = with pkgs; [ desktop-file-utils ];

            installPhase = ''
              mkdir -p $out/share/applications
              cp $src/share/applications/${firefox.meta.mainProgram}.desktop $out/share/applications
              ln -s $src/share/icons $out/share/icons
              ln -s $src/bin $out/bin
              desktop-file-edit \
                --set-key="Exec" --set-value="${lib.getExe firefox} ${args} %U" \
                $out/share/applications/${firefox.meta.mainProgram}.desktop
            '';
          }
        );
    };
}
