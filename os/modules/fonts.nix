{ pkgs, ... }:
{
  fonts = {
    packages = with pkgs; [
      inter
      noto-fonts-color-emoji
      liberation_ttf
      nur.repos.dtomvan.afio-font
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
}
