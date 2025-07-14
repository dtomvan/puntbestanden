{
  flake.modules.nixos.fonts =
    { pkgs, ... }:
    {
      fonts = {
        packages = with pkgs; [
          inter
          noto-fonts-color-emoji
          liberation_ttf
          nur.repos.dtomvan.afio-font-bin
        ];

        fontconfig = {
          useEmbeddedBitmaps = true;
          defaultFonts = {
            serif = [ "Liberation Serif" ];
            sansSerif = [ "Inter" ];
            monospace = [ "Afio" ];
          };
        };
      };
    };
}
