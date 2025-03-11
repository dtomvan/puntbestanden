{ pkgs, ... }: {
  fonts = {
    packages = with pkgs; [
      inter
      noto-fonts
      noto-fonts-emoji
      liberation_ttf
      afio-font
    ];

    fontconfig = {
      useEmbeddedBitmaps = true;
      serif = ["Liberation Serif"];
      sansSerif = ["Inter"];
      monospace = ["Afio"];
    };
  };
}
